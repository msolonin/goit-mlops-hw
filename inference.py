from fastapi import FastAPI, File, UploadFile
import torch
from torchvision import transforms
from PIL import Image
import io
import uvicorn
import urllib

PROBABILITIES = 3
app = FastAPI(title="Image Classification API", description="Top-3 classification using MobileNetV2")

model = torch.jit.load("model.pt")
model.eval()


url = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt"
imagenet_classes = urllib.request.urlopen(url).read().decode("utf-8").split("\n")

preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    image_bytes = await file.read()
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    input_tensor = preprocess(img).unsqueeze(0)
    with torch.no_grad():
        output = model(input_tensor)
        probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top3_prob, top3_id = torch.topk(probabilities, PROBABILITIES)
    results = []
    for i in range(PROBABILITIES):
        class_name = imagenet_classes[top3_id[i]]
        probability = float(top3_prob[i])
        results.append({
            "class": class_name,
            "probability": probability
        })
    return {"filename": file.filename, "top3": results}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
