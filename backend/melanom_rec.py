import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import os
import tempfile
from flask import request, jsonify

class SkinCancerClassifier:
    def __init__(self, model_path):
        self.model = tf.keras.models.load_model(model_path)

    def preprocess_image(self, image_file):
        # Save the uploaded file to a temporary location
        temp_filename = os.path.join(tempfile.gettempdir(), image_file.filename)
        image_file.save(temp_filename)

        # Load the image from the temporary file
        img = image.load_img(temp_filename, target_size=(150, 150))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array /= 255.0  # Normalize pixel values

        # Clean up temporary file
        os.remove(temp_filename)

        return img_array

    def predict(self, img_array):
        predictions = self.model.predict(img_array)
        probability_malignant = predictions[0][0]
        probability_benign = 1 - probability_malignant
        return probability_malignant, probability_benign


def evalimage():
    # Check if request contains images
    if 'images' not in request.files:
        return jsonify({'error': 'No images provided'}), 400

    # Path to the pre-trained model
    model_path = 'C:/xampp/htdocs/skinglow/backend/skin_cancer_model_2.keras'

    # Create an instance of SkinCancerClassifier
    classifier = SkinCancerClassifier(model_path)

    # Get the image files from the request
    image_files = request.files.getlist('images')

    if not image_files:
        return jsonify({'error': 'No images provided'}), 400

    # Initialize lists to store probabilities
    probabilities_malignant = []
    probabilities_benign = []

    # Iterate over each image file
    for image_file in image_files:
        # Preprocess the image
        new_image = classifier.preprocess_image(image_file)

        # Get predictions
        probability_malignant, probability_benign = classifier.predict(new_image)
        probabilities_malignant.append(probability_malignant)
        probabilities_benign.append(probability_benign)

    # Calculate average probabilities
    avg_probability_malignant = np.mean(probabilities_malignant)
    avg_probability_benign = np.mean(probabilities_benign)

    print(avg_probability_benign, "\n", avg_probability_malignant)
    return jsonify({
        'probability_melanoma': float(avg_probability_malignant),
        'probability_mole': float(avg_probability_benign)
    })