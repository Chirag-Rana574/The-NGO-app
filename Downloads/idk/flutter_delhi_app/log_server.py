import os
import json
import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler

LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'app_activity_logs.txt')

class LogRequestHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        # Handle CORS preflight
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        if self.path == '/log':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            try:
                log_entry = json.loads(post_data.decode('utf-8'))
                
                # Format log entry
                timestamp = log_entry.get('timestamp', datetime.datetime.now().isoformat())
                log_type = log_entry.get('type', 'info').upper()
                platform = log_entry.get('platform', 'unknown').upper()
                message = log_entry.get('message', '')
                stack_trace = log_entry.get('stackTrace', '')
                
                formatted_log = f"[{timestamp}] [{platform}] [{log_type}] {message}\n"
                if stack_trace:
                    formatted_log += f"Stack Trace:\n{stack_trace}\n"
                formatted_log += "-" * 80 + "\n"
                
                # Print to terminal
                color = "\033[92m" if log_type == "INFO" else "\033[91m"
                reset = "\033[0m"
                print(f"{color}[{log_type}]{reset} {message}")
                
                # Write to file
                with open(LOG_FILE, 'a', encoding='utf-8') as f:
                    f.write(formatted_log)
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'status': 'logged'}).encode('utf-8'))
            except Exception as e:
                print(f"Error parsing log: {e}")
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        if self.path == '/logs' or self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            if os.path.exists(LOG_FILE):
                with open(LOG_FILE, 'r', encoding='utf-8') as f:
                    self.wfile.write(f.read().encode('utf-8'))
            else:
                self.wfile.write(b"No logs recorded yet.\n")
        elif self.path == '/clear':
            if os.path.exists(LOG_FILE):
                os.remove(LOG_FILE)
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(b"Logs cleared successfully.\n")
        else:
            self.send_response(404)
            self.end_headers()

def run_server(port=8089):
    server_address = ('0.0.0.0', port)
    httpd = HTTPServer(server_address, LogRequestHandler)
    print(f"🚀 Logger server listening on http://0.0.0.0:{port}")
    print(f"📁 Log file location: {LOG_FILE}")
    print(f"🌐 View logs at http://localhost:{port}/logs")
    print(f"🧹 Clear logs at http://localhost:{port}/clear")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping logger server...")
        httpd.server_close()

if __name__ == '__main__':
    run_server()
