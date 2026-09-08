#!/usr/bin/env python3
"""Minimal HTTP listener for the first HackTV firmware modification test."""

from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DOWNLOADS = {
    "/dropbear": ROOT / "dropbear-build" / "out" / "dropbear",
    "/dropbearkey": ROOT / "dropbear-build" / "out" / "dropbearkey",
    "/tinycap": ROOT / "dropbear-build" / "tinyalsa-out" / "tinycap",
    "/tinypcminfo": ROOT / "dropbear-build" / "tinyalsa-out" / "tinypcminfo",
}


class ProbeHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        now = datetime.now().astimezone().isoformat(timespec="seconds")
        print(f"[{now}] GET {self.path} from {self.client_address[0]}", flush=True)
        download = DOWNLOADS.get(self.path)
        if download is not None:
            if not download.is_file():
                self.send_error(404, "Dropbear binary not found")
                return
            body = download.read_bytes()
            content_type = "application/octet-stream"
        else:
            body = b"hacktv-probe-ok\n"
            content_type = "text/plain"
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    address = ("0.0.0.0", 8000)
    print("Listening for the TV probe on http://0.0.0.0:8000/", flush=True)
    ThreadingHTTPServer(address, ProbeHandler).serve_forever()
