<!-- SVG HEADER -->
<p align="center">
  <svg width="800" height="200" viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#0a0a1a"/>
        <stop offset="100%" style="stop-color:#1a0a2e"/>
      </linearGradient>
      <linearGradient id="textGrad" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" style="stop-color:#FF6B35"/>
        <stop offset="50%" style="stop-color:#F7C59F"/>
        <stop offset="100%" style="stop-color:#FF6B35"/>
      </linearGradient>
      <filter id="glow">
        <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
        <feMerge>
          <feMergeNode in="coloredBlur"/>
          <feMergeNode in="SourceGraphic"/>
        </feMerge>
      </filter>
    </defs>
    
    <!-- Fondo -->
    <rect width="800" height="200" fill="url(#bgGrad)" rx="20"/>
    
    <!-- Líneas decorativas -->
    <line x1="50" y1="30" x2="750" y2="30" stroke="#FF6B35" stroke-width="2" opacity="0.5"/>
    <line x1="50" y1="170" x2="750" y2="170" stroke="#FF6B35" stroke-width="2" opacity="0.5"/>
    
    <!-- Texto principal -->
    <text x="400" y="80" font-family="Arial Black, sans-serif" font-size="50" fill="url(#textGrad)" text-anchor="middle" filter="url(#glow)">
      SOUTH BRONX
    </text>
    
    <!-- Subtítulo -->
    <text x="400" y="120" font-family="Arial, sans-serif" font-size="24" fill="#ffffff" text-anchor="middle" opacity="0.9">
      ⚡ Script del Boogie Down ⚡
    </text>
    
    <!-- Versión -->
    <text x="400" y="150" font-family="monospace" font-size="14" fill="#FF6B35" text-anchor="middle" opacity="0.7">
      v1.0.0 • MIT License
    </text>
    
    <!-- Elementos decorativos -->
    <circle cx="70" cy="170" r="4" fill="#FFD700" opacity="0.6"/>
    <circle cx="730" cy="170" r="4" fill="#FFD700" opacity="0.6"/>
    <circle cx="70" cy="30" r="4" fill="#FFD700" opacity="0.6"/>
    <circle cx="730" cy="30" r="4" fill="#FFD700" opacity="0.6"/>
  </svg>
</p>

---

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.8%2B-3776AB?style=flat-square&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/Bronx-Boogie_Down-orange?style=flat-square&labelColor=black"/>
</p>

---

<!-- SVG STATS CARD -->
<div align="center">
  <svg width="700" height="120" viewBox="0 0 700 120">
    <rect width="700" height="120" rx="10" fill="#0a0a1a" stroke="#FF6B35" stroke-width="2"/>
    
    <text x="50" y="45" font-family="monospace" font-size="14" fill="#FF6B35">📊 STATS</text>
    
    <rect x="50" y="60" width="80" height="8" rx="4" fill="#FF6B35" opacity="0.3"/>
    <rect x="50" y="60" width="65" height="8" rx="4" fill="#FF6B35"/>
    <text x="140" y="68" font-family="monospace" font-size="12" fill="#ffffff">85% Eficiencia</text>
    
    <rect x="250" y="60" width="80" height="8" rx="4" fill="#4CAF50" opacity="0.3"/>
    <rect x="250" y="60" width="70" height="8" rx="4" fill="#4CAF50"/>
    <text x="340" y="68" font-family="monospace" font-size="12" fill="#ffffff">92% Precisión</text>
    
    <rect x="450" y="60" width="80" height="8" rx="4" fill="#FFD700" opacity="0.3"/>
    <rect x="450" y="60" width="75" height="8" rx="4" fill="#FFD700"/>
    <text x="540" y="68" font-family="monospace" font-size="12" fill="#ffffff">98% Confianza</text>
  </svg>
</div>

---

## 🗽 **¿Qué es esto?**

Un script [**describe tu script aquí**] diseñado con la misma **resiliencia**, **flow** y **autenticidad** del South Bronx.

<div align="center">
  <svg width="600" height="2" viewBox="0 0 600 2">
    <line x1="0" y1="1" x2="600" y2="1" stroke="#FF6B35" stroke-width="2"/>
  </svg>
</div>

---

## 📦 **Instalación rápida**

```bash
# Clona el repositorio
git clone https://github.com/yourusername/south-bronx-script.git

# Entra al directorio
cd south-bronx-script

# Instala dependencias
pip install -r requirements.txt
