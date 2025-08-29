import torch.nn as nn
from torchvision import models, transforms

# -----------------------------
# Model Setup
# -----------------------------
def get_densenet_model(num_classes=3):
    model = models.densenet169(pretrained=True)
    # Replace classifier
    model.classifier = nn.Linear(model.classifier.in_features, num_classes)
    return model

# -----------------------------
# Preprocessing for DenseNet
# -----------------------------
densenet_transforms = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485,0.456,0.406],
                         std=[0.229,0.224,0.225])
])

# -----------------------------
# Training Loop (simplified)
# -----------------------------
def train_classifier(model, dataloader, device, epochs=10):
    model.to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

    model.train()
    for epoch in range(epochs):
        for imgs, labels in dataloader:
            imgs, labels = imgs.to(device), labels.to(device)
            outputs = model(imgs)
            loss = criterion(outputs, labels)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        print(f"Epoch {epoch+1}/{epochs}, Loss: {loss.item():.4f}")
