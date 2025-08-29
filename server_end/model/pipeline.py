import torch 


def hybrid_inference(detector, classifier, image, device, detection_threshold=0.5):
    detector.eval()
    classifier.eval()
    with torch.no_grad():
        # Step 1: Detection
        img_tensor = densenet_transforms(image).unsqueeze(0).to(device)
        detections = detector([img_tensor.squeeze(0)])
        
        results = []
        for box, score, label in zip(detections[0]['boxes'], 
                                     detections[0]['scores'], 
                                     detections[0]['labels']):
            if score > detection_threshold:
                # Step 2: Crop ROI
                xmin, ymin, xmax, ymax = box.int()
                roi = image.crop((xmin, ymin, xmax, ymax))
                roi_tensor = densenet_transforms(roi).unsqueeze(0).to(device)
                # Step 3: Classification
                class_probs = torch.softmax(classifier(roi_tensor), dim=1)
                pred_class = class_probs.argmax(dim=1).item()
                confidence = class_probs.max().item()
                results.append({"box": box.tolist(),
                                "pred_class": pred_class,
                                "confidence": confidence})
    return results
