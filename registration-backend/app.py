from flask import Flask, request, render_template_string, jsonify
import subprocess

app = Flask(__name__)

# HTML template for the form, embedded in Flask using render_template_string
html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register New Matrix User</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            padding: 20px;
        }
        .form-container {
            max-width: 400px;
            margin: auto;
        }
        label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 8px;
            margin-bottom: 20px;
        }
        button {
            padding: 10px 15px;
            background-color: #28a745;
            color: white;
            border: none;
            cursor: pointer;
        }
        button:hover {
            background-color: #218838;
        }
        .message {
            margin-top: 20px;
            font-size: 14px;
        }
        .success {
            color: green;
        }
        .error {
            color: red;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }
        .inter-tight {
  font-family: "Inter Tight", sans-serif;
  font-optical-sizing: auto;
  font-weight: 100;
  font-style: normal;
}
    </style>
    <link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter+Tight:ital,wght@0,100..900;1,100..400&display=swap" rel="stylesheet">
</head>
<body>

<div class="form-container inter-tight">
    <div class="logo">
    <img width="70" height="70" src="/static/ciphera.png" />
    <h1>Ciphera</h1>
    </div>
    <h1>Register New Matrix User</h1>
    <form method="POST" action="/">
        <label for="username">Username</label>
        <input type="text" id="username" name="username" required>

        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>

        <label for="confirm-password">Confirm Password</label>
        <input type="password" id="confirm-password" name="confirm-password" required>

        <button type="submit">Register</button>
    </form>

    {% if message %}
    <div class="message {{ message_class }}">{{ message }}</div>
    {% endif %}
</div>

</body>
</html>
"""

@app.route('/register-user-cli', methods=['GET'])
def register_user():
    username = request.args.get('username')
    password = request.args.get('password')

    if not username or not password:
        return jsonify({'error': 'Username and password are required'}), 400

    try:
        command = [
            'sudo', 'docker', 'exec', '-it', 'synapse',
            'register_new_matrix_user', 'http://localhost:8008',
            '-c', '/data/homeserver.yaml', '-u', username, '-p', password, '--no-admin'
        ]
        
        result = subprocess.run(command, capture_output=True, text=True)

        if result.returncode == 0:
            return jsonify({'message': f'User {username} registered successfully.', 'output': result.stdout}), 200
        else:
            return jsonify({'error': result.stderr}), 500

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        confirm_password = request.form.get('confirm-password')

        if password != confirm_password:
            return render_template_string(html_template, message="Passwords do not match", message_class="error")

        try:
            command = [
                'sudo', 'docker', 'exec', '-it', 'synapse',
                'register_new_matrix_user', 'http://localhost:8008',
                '-c', '/data/homeserver.yaml', '-u', username, '-p', password, '--no-admin'
            ]

            result = subprocess.run(command, capture_output=True, text=True)

            if result.returncode == 0:
                success_message = f"Great! Now you can go back to your client and sign in to your homeserver at http://localhost:8008"
                return render_template_string(html_template, message=success_message, message_class="success")
            else:
                return render_template_string(html_template, message=f"Error: {result.stderr}", message_class="error")

        except Exception as e:
            return render_template_string(html_template, message=f"Error: {str(e)}", message_class="error")

    return render_template_string(html_template)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

