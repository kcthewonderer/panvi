from flask import Flask, jsonify, request
from flask_cors import CORS
from io import BytesIO
from services.storage_service import add_food_item
from utils.auth_util import auth_required
from config.firebase_configs import firestore_db



print("Firestore connection active:", firestore_db._client.project)  # Should show your project ID
panvi = Flask(__name__)
CORS(panvi)  # Enable CORS for all routes
@auth_required
def create_food_item():
    try:
        # Get form data
        item_data = {
            'name': request.form.get('name'),
            'category': request.form.get('category'),
            'quantity': int(request.form.get('quantity', 1)),
            'expiration_date': request.form.get('expiration_date'),
            'purchase_date': request.form.get('purchase_date')
        }
        
        # Handle file upload
        image_file = request.files.get('image')
        file_stream = BytesIO(image_file.read()) if image_file else None
        
        if file_stream:
            file_stream.seek(0)  # Important for reading
        
        # Add item
        result = add_food_item(request, item_data, file_stream)
        
        return jsonify({
            'success': True,
            'data': result
        }), 201
    
    except Exception as e:
        return jsonify({'success': False,
            'error': str(e)
        }), 400
        
@panvi.route('/api/test', methods=['GET'])
def test():
    return jsonify({"message": "Hello from Flask!"})

# Example POST route
@panvi.route('/api/data', methods=['POST'])
def receive_data():
    data = request.json  # Get data sent from Flutter
    return jsonify({"received_data": data})

if __name__ == '__main__':
    panvi.run(debug=True)  # Run the Flask app