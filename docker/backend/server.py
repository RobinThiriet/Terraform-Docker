import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

import redis


APP_ENV = os.getenv("APP_ENV", "dev")
APP_NAME = os.getenv("APP_NAME", "local-platform")
APP_MESSAGE = os.getenv("APP_MESSAGE", "Hello from the backend")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))


def fetch_cache_status():
    try:
        client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, socket_timeout=1)
        ping = client.ping()
        counter = client.incr(f"{APP_NAME}:{APP_ENV}:requests")
        return {
            "reachable": bool(ping),
            "request_counter": counter,
        }
    except Exception as exc:  # pragma: no cover - runtime safeguard
        return {
            "reachable": False,
            "error": str(exc),
        }


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload, status=200):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_args):
        return

    def do_GET(self):
        if self.path == "/healthz":
            self._send_json({"status": "ok", "service": "backend", "environment": APP_ENV})
            return

        if self.path == "/api/info":
            payload = {
                "service": "backend",
                "app_name": APP_NAME,
                "environment": APP_ENV,
                "message": APP_MESSAGE,
                "cache": fetch_cache_status(),
            }
            self._send_json(payload)
            return

        self._send_json({"error": "Not found"}, status=404)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), Handler)
    server.serve_forever()

