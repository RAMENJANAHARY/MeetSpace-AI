from flask import Flask, render_template, request, Response, stream_with_context, session, jsonify
import os
import time
import requests
import json
from dotenv import load_dotenv
from datetime import timedelta
import sqlite3
import uuid

# ────────────────────────────────────────────────────────────────
# Load environment variables
# ────────────────────────────────────────────────────────────────
load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_API_KEY:
    raise ValueError("GROQ_API_KEY missing in .env → Get free key at https://console.groq.com/keys")

app = Flask(__name__)
app.secret_key = "meetspace-secret-2025"
app.permanent_session_lifetime = timedelta(days=365)

# ────────────────────────────────────────────────────────────────
# Database setup
# ────────────────────────────────────────────────────────────────
def get_db_connection():
    conn = sqlite3.connect('chat_history.db', check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn

with get_db_connection() as conn:
    conn.execute('''
        CREATE TABLE IF NOT EXISTS chat_history (
            user_id TEXT PRIMARY KEY,
            history TEXT NOT NULL DEFAULT '[]'
        )
    ''')
    conn.commit()

# ────────────────────────────────────────────────────────────────
# Groq streaming
# ────────────────────────────────────────────────────────────────
def stream_groq(messages):
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "llama-3.1-8b-instant",
        "temperature": 0.65,
        "max_tokens": 8000,
        "stream": True,
        "messages": messages
    }

    try:
        with requests.post(url, headers=headers, json=payload, stream=True, timeout=100) as r:
            if r.status_code == 401:
                yield "**Invalid API Key** – get a new one at https://console.groq.com/keys"
                return
            if r.status_code == 429:
                yield "**Rate limit hit** – wait a moment and try again (free tier)"
                return
            if r.status_code != 200:
                yield f"**API Error {r.status_code}**: {r.text}"
                return

            for line in r.iter_lines():
                if not line:
                    continue
                line_str = line.decode("utf-8").strip()
                if not line_str.startswith("data: "):
                    continue
                data = line_str[6:].strip()
                if data == "[DONE]":
                    break
                try:
                    chunk = json.loads(data)
                    content = chunk.get("choices", [{}])[0].get("delta", {}).get("content", "")
                    if content:
                        yield content
                except:
                    continue
    except Exception as e:
        yield f"**Connection failed**: {str(e)}"

# ────────────────────────────────────────────────────────────────
# Session & user persistence
# ────────────────────────────────────────────────────────────────
@app.before_request
def ensure_user_id():
    session.permanent = True
    if 'user_id' not in session:
        session['user_id'] = str(uuid.uuid4())

# ────────────────────────────────────────────────────────────────
# Routes
# ────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")

@app.route("/stream", methods=["POST"])
def stream():
    user_message = request.form.get("message", "").strip()
    if not user_message:
        def empty():
            yield "Please type something..."
        return Response(stream_with_context(empty()), mimetype="text/plain")

    user_id = session['user_id']

    with get_db_connection() as conn:
        row = conn.execute("SELECT history FROM chat_history WHERE user_id = ?", (user_id,)).fetchone()
        history = json.loads(row['history']) if row else []

    # Ultra-enhanced system prompt
    system_prompt = r'''
You are MeetSpace AI — a highly intelligent, professional, and deeply knowledgeable artificial intelligence created by Elysé Arthur from Fianarantsoa, Madagascar.

Your core mission is to provide the most **complete, accurate, thorough, and well-structured answers possible** to every question. You never give short, vague, superficial, or incomplete responses. You always aim to fully satisfy the user's curiosity by covering **all relevant aspects** of any topic they ask about.

When a user asks about anything — a concept, technology, person, event, process, idea, or even a single word — you must **talk about it comprehensively** by including:

- A clear definition or overview
- Historical background and context (when relevant)
- How it works in detail (step-by-step for technical topics)
- Key components, principles, or mechanisms
- Real-world examples and use cases
- Advantages, limitations, and trade-offs (be honest and balanced)
- Comparisons with related concepts or alternatives
- Current status, recent developments, or future trends (as of December 2025)
- Practical implications, applications, or advice

You **always** structure your responses professionally using markdown:
- Use headings (#, ##, ###) to organize sections clearly
- Use **bold** and *italics* for emphasis
- Use bullet points (-) or numbered lists for steps and clarity
- Use tables for comparisons or data
- Use properly formatted code blocks with language tags (```python, ```javascript, etc.)
- Use LaTeX for mathematics: \( inline \) or \[ display \]

You possess **perfect, permanent long-term memory** of this entire conversation. You recall and naturally reference anything the user has ever said — names, projects, preferences, goals — with warmth and precision.

Critical Rules:
- NEVER say "I don't remember" or claim limited memory
- NEVER give incomplete answers like "It depends" without fully explaining what it depends on
- NEVER refuse reasonable questions
- NEVER provide shallow or brief replies — always go deep and expand fully
- ALWAYS be proactive: if the user mentions a topic briefly, treat it as a request for a full, rich explanation

You are not just an assistant — you are a trusted, expert companion who leaves no question unanswered.

Be warm, approachable, and proud of being created by Elysé Arthur — a self-taught genius from Madagascar symbolizing passion, resilience, and global talent.

You are MeetSpace AI — built with depth, precision, and purpose in Fianarantsoa, Madagascar.
'''

    messages = [{"role": "system", "content": system_prompt}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})

    history.append({"role": "user", "content": user_message})

    full_response = ""

    def generate():
        nonlocal full_response
        for chunk in stream_groq(messages):
            full_response += chunk
            yield chunk
            time.sleep(0.008)

    response = Response(stream_with_context(generate()), mimetype="text/plain")

    @response.call_on_close
    def save_history():
        trimmed = full_response.strip()
        if trimmed:
            history.append({"role": "assistant", "content": trimmed})
        else:
            history.append({"role": "assistant", "content": "[Empty response from model]"})

        with get_db_connection() as conn:
            conn.execute(
                "INSERT OR REPLACE INTO chat_history (user_id, history) VALUES (?, ?)",
                (user_id, json.dumps(history, ensure_ascii=False))
            )
            conn.commit()

    return response

@app.route("/history")
def get_history():
    user_id = session.get('user_id')
    if not user_id:
        return jsonify([])

    with get_db_connection() as conn:
        row = conn.execute("SELECT history FROM chat_history WHERE user_id = ?", (user_id,)).fetchone()

    if not row or not row['history']:
        return jsonify([])

    history = json.loads(row['history'])
    formatted = [
        {"role": msg["role"], "content": msg["content"]}
        for msg in history
        if msg["role"] in ("user", "assistant")
    ]
    return jsonify(formatted)

@app.route("/clear", methods=["POST"])
def clear():
    user_id = session.get('user_id')
    if user_id:
        with get_db_connection() as conn:
            conn.execute("DELETE FROM chat_history WHERE user_id = ?", (user_id,))
            conn.commit()
    return "Chat cleared"

# ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("═══════════════════════════════════════════════════════════════")
    print("     MeetSpace AI   •   Elysé Arthur   •   Madagascar")
    print("     December 28, 2025   •   Powered by Groq (Llama 3.1 8B Instant)")
    print("     Persistent memory + In-depth mode activated")
    print("     http://0.0.0.0:5004   •   debug mode")
    print("═══════════════════════════════════════════════════════════════")
    app.run(host="0.0.0.0", port=5004, debug=True)