# SC25_ROVAI_AD
This is the repository for the SC25 ROVAI Artifact Description.

ROVAI enables scalable and high-throughput processing of massive 3D tomographic datasets. Our approach overcomes key challenges, such as the high memory requirements of vision models, the lack of labeled training data, and storage I/O bottlenecks. This seamless fusion of imaging and AI analytics facilitates automated defect detection, material composition analysis, and lifespan prediction.

## Repository Structure
The repository includes the following directories and files:​

```
SC25_ROVAI_AD/
├── 1_XCT/
│   ├── without_pipeline/
│   └── with_pipeline/
├── 2_AI/
├── 3_Fuse_XCT_AI/
│   ├── runtime/
│   ├── strong_scaling/
│   └── weak_scaling/
├── config.conf
└── README.md
```

## Description

This repository appears to be organized into three main modules:

- **1_XCT**: $H^3$ Imaging: High-Performance, High-Throughput, and High-Resolution X-ray Computed Tomography (XCT).
- **2_AI**: State-of-the-Art ViT for High-Resolution 3D Segmentation.
- **3_Fuse_XCT_AI**: Efficient Fusion of XCT Computation and AI Inference.

## Usage

Clone the repository:

```bash
git clone https://github.com/wudu98/SC25_ROVAI_AD.git
cd SC25_ROVAI_AD
```