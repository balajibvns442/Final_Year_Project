from flask import Flask, request, jsonify, send_file
import mysql.connector
from io import BytesIO
import os 
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# ✅ MySQL connection
db = mysql.connector.connect(
    host = os.getenv("DB_HOST") ,
    user = os.getenv("DB_USER") ,
    password = os.getenv("DB_PASSWORD") ,
    database = os.getenv("DB_NAME")
)
cursor = db.cursor(dictionary=True)

# ✅ Upload image with description
@app.route('/upload', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    description = request.form.get("description", "No description")

    data = file.read()
    sql = "INSERT INTO images (name, image, description) VALUES (%s, %s, %s)"
    cursor.execute(sql, (file.filename, data, description))
    db.commit()

    return jsonify({"message": "Image uploaded!", "id": cursor.lastrowid})

# ✅ Get image by ID (returns binary)
@app.route('/image/<int:id>', methods=['GET'])
def get_image(id):
    cursor.execute("SELECT name, image FROM images WHERE id=%s", (id,))
    row = cursor.fetchone()
    if not row:
        return jsonify({"error": "Not found"}), 404

    return send_file(BytesIO(row["image"]), mimetype="image/jpeg", as_attachment=False, download_name=row["name"])

# ✅ Get all images (returns base64 + description)
@app.route('/image/all', methods=['GET'])
def get_all_images():
    cursor.execute("SELECT id, name, image, description FROM images")
    rows = cursor.fetchall()
    if not rows:
        return jsonify({"error": "No images found"}), 404

    images = []
    for row in rows:
        images.append({
            "id": row["id"],
            "name": row["name"],
            "description": row["description"],
            "image": row["image"].decode("latin1")  # ⚠️ use base64 normally
        })

    return jsonify(images)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=3001, debug=True)
