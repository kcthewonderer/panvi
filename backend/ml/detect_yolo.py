import cv2
import numpy as np
from ultralytics import YOLO
import torch

print(torch.backends.mps.is_available())

model = YOLO("yolov8n.pt")



# Train the model
train_results = model.train(
    data="ultralytics/ultralytics/cfg/datasets/coco8.yaml",  # path to dataset YAML
    epochs=100,  # number of training epochs
    imgsz=640,  # training image size
    device="cpu",  # device to run on, i.e. device=0 or device=0,1,2,3 or device=cpu
)

# Evaluate model performance on the validation set
metrics = model.val()

# Perform object detection on an image
results = model("darknet/data/horses.png")
results[0].show()

# Export the model to ONNX format
path = model.export(format="onnx")  # return path to exported model'''

'''import cv2
import pytesseract
import numpy as np
import tensorflow as tf

# Load the image
image_path = 'darknet/data/horses.png'
image = cv2.imread(image_path)

# Load a pre-trained YOLO model for object detection
# (Make sure to download the weights and config for YOLOv3 or YOLOv5)
# Replace 'yolo_weights' and 'yolo_cfg' with paths to YOLO weights and config files.
modelConfiguration = 'darknet/cfg/yolov4.cfg'
modelWeights = 'darknet/yolov4.weights'
net = cv2.dnn.readNet(modelWeights, modelConfiguration)
layer_names = net.getLayerNames()
output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]

# Prepare the image for YOLO
blob = cv2.dnn.blobFromImage(image, 1 / 255.0, (416, 416), swapRB=True, crop=False)
net.setInput(blob)
outputs = net.forward(output_layers)

# Parse YOLO's outputs for object detection
class_ids = []
confidences = []
boxes = []
height, width = image.shape[:2]
for output in outputs:
    for detection in output:
        scores = detection[5:]
        class_id = np.argmax(scores)
        confidence = scores[class_id]
        if confidence > 0.5:  # confidence threshold
            center_x, center_y, w, h = (detection[0:4] * np.array([width, height, width, height])).astype("int")
            x = int(center_x - w / 2)
            y = int(center_y - h / 2)
            boxes.append([x, y, int(w), int(h)])
            confidences.append(float(confidence))
            class_ids.append(class_id)

# Draw bounding boxes
for i in range(len(boxes)):
    x, y, w, h = boxes[i]
    label = str(class_ids[i])  # Replace with actual label mapping
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
    cv2.putText(image, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

# OCR for text detection
# Convert the image to grayscale and apply OCR
gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
text = pytesseract.image_to_string(gray_image)

# Show the results
cv2.imshow("Detected Objects", image)
print("Detected Text:", text)
cv2.waitKey(0)
cv2.destroyAllWindows()'''