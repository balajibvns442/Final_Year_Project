import torch
import torchvision
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.transforms import functional as F
from torch.utils.data import Dataset, DataLoader
import os
from PIL import Image

# -----------------------------
# Custom Dataset for Detection
# -----------------------------
class OralLesionDataset(Dataset):
    def __init__(self, image_dir, annotations, transforms=None):
        self.image_dir = image_dir
        self.annotations = annotations  # dict: {img_name: {"boxes": [], "labels": []}}
        self.transforms = transforms
        self.images = list(annotations.keys())

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):
        img_name = self.images[idx]
        img_path = os.path.join(self.image_dir, img_name)
        img = Image.open(img_path).convert("RGB")
        boxes = torch.tensor(self.annotations[img_name]["boxes"], dtype=torch.float32)
        labels = torch.tensor(self.annotations[img_name]["labels"], dtype=torch.int64)

        target = {"boxes": boxes, "labels": labels}

        if self.transforms:
            img = self.transforms(img)

        return img, target

# -----------------------------
# Model Initialization
# -----------------------------
def get_faster_rcnn_model(num_classes):
    model = torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=True)
    # Replace the classifier with new head
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
    return model

# -----------------------------
# Training Loop (simplified)
# -----------------------------
def train_detector(model, dataloader, device, epochs=10):
    model.to(device)
    model.train()
    optimizer = torch.optim.SGD(model.parameters(), lr=0.005,
                                momentum=0.9, weight_decay=0.0005)
    for epoch in range(epochs):
        for imgs, targets in dataloader:
            imgs = list(img.to(device) for img in imgs)
            targets = [{k: v.to(device) for k, v in t.items()} for t in targets]

            loss_dict = model(imgs, targets)
            losses = sum(loss for loss in loss_dict.values())

            optimizer.zero_grad()
            losses.backward()
            optimizer.step()

        print(f"Epoch {epoch+1}/{epochs}, Loss: {losses.item():.4f}")
