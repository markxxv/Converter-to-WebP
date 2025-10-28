# 🖼️ Image Optimizer for macOS

A tiny macOS tool to **optimize images before publishing to the web**.  
Double‑click **`converter.command`** and it will:
- Convert `AVIF`, `JPG`, `JPEG`, `PNG` → **WebP**
- Resize to **max width 1900px** (keeps aspect ratio)
- Strip metadata
- Also resize existing **.webp** files
- Save results into a `webp/` subfolder (originals stay untouched)

---

## 🚀 How to Use (Finder)
1. Put **`converter.command`** in the folder with your images.  
2. **Double‑click** the file to run.  
3. When it finishes, check the new **`webp/`** folder.

> First run on macOS may show a security prompt. If so, right‑click → **Open**.

---

## 🧰 Requirements
- macOS (Apple Silicon or Intel)  
- Internet connection on first run (installs ImageMagick & codecs via Homebrew, automatically)

---

## 📦 For Git Users (optional)
If you cloned the repo and the file is not marked executable:
```bash
chmod +x converter.command
```
Then you can double‑click it in Finder, or run from Terminal:
```bash
./converter.command
```

---

## 📂 Example
```
project/
├── converter.command
├── photo1.jpg
├── logo.png
└── webp/
    ├── photo1.webp
    └── logo.webp
```

---

## ❓Notes
- You can re‑run it any time; it safely reprocesses or updates outputs.  
- Perfect for **pre‑publishing optimization** before uploading to your site/CMS.

---

## 🧑‍💻 License
MIT — free to use, modify, and share.  
Made with ❤️ for the community.
