import os
import cv2

INPUT_DIR = "dataset"
OUTPUT_DIR = "dataset_flipped"

os.makedirs(OUTPUT_DIR, exist_ok=True)

for class_name in os.listdir(INPUT_DIR):
    class_path = os.path.join(INPUT_DIR, class_name)
    output_class_path = os.path.join(OUTPUT_DIR, class_name)

    if not os.path.isdir(class_path):
        continue

    os.makedirs(output_class_path, exist_ok=True)

    for img_name in os.listdir(class_path):
        img_path = os.path.join(class_path, img_name)

        img = cv2.imread(img_path)
        if img is None:
            print(f"Skipping unreadable image: {img_path}")
            continue

        # Save original
        cv2.imwrite(
            os.path.join(output_class_path, img_name),
            img
        )

        # Horizontal flip only (safe for oral cancer)
        flipped = cv2.flip(img, 1)

        name, ext = os.path.splitext(img_name)
        flipped_name = f"{name}_hflip{ext}"

        cv2.imwrite(
            os.path.join(output_class_path, flipped_name),
            flipped
        )

print("✅ Horizontal flipping completed successfully.")
