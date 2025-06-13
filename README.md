# 🏀 Orenji – Posture Evaluation for Basketball Shooting

Orenji adalah aplikasi iOS berbasis **SwiftUI** dan **Vision Framework** yang membantu pemain basket mengevaluasi **postur saat melakukan shooting**, baik melalui **analisa rekaman video** maupun **deteksi secara real-time**.  
Aplikasi ini mendeteksi sudut tubuh seperti siku dan bahu, lalu memberikan **feedback instan** secara visual dan haptic untuk membantu perbaikan teknik.

---

## 🚀 Fitur Utama

- Deteksi postur tubuh secara real-time menggunakan kamera dan Vision.
- Evaluasi sudut tubuh (Upper Body dan Lower Body) menggunakan analisis sudut.
- Feedback visual (teks dan warna) untuk koreksi postur.
- Analisa dari **rekaman video** maupun input kamera langsung.
- Arsitektur modular menggunakan **MVVM**.
- Dukungan untuk **Apple Watch Companion App**:
  - Tampilkan status postur di pergelangan tangan.
  - Haptic feedback jika postur tidak ideal.
- Siap diintegrasikan dengan Core Data, CloudKit, dan Xcode Cloud CI/CD.

---

## 🧰 Tech Stack

- `SwiftUI`
- `Vision` (Human Body Pose Detection)
- `AVFoundation` (Video & camera input)
- `WatchKit` (Apple Watch companion)
- `WatchConnectivity` (iPhone ⇄ Watch sync)
- `CoreGraphics` (Angle calculation)
- `MVVM Architecture`
- `Xcode Cloud` / GitHub Actions (optional)

---

## ⌚ Apple Watch Companion

Orenji juga tersedia dalam bentuk **Apple Watch app** yang terhubung langsung dengan aplikasi utama iPhone.

### Fitur:
- Sinkronisasi status postur melalui `WatchConnectivity`.
- Tampilkan ringkasan feedback postur saat latihan di lapangan.
- Haptic feedback otomatis saat postur dinilai buruk/salah.
- Antarmuka sederhana, praktis, dan mudah dipantau saat latihan.

---

<h2 align="center">🙌 Kontributor</h2>

<table align="center">
  <thead>
    <tr>
      <th>Peran</th>
      <th>Nama dan Profil LinkedIn</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>🎨 Design</td>
      <td><a href="https://www.linkedin.com/in/hanifahlubis/">Hanifah Lubis</a></td>
    </tr>
     <tr>
      <td>🧑‍💻 Developer</td>
      <td><a href="https://www.linkedin.com/in/aditputrafirmansyah/">Adit Putra Firmansyah</a></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="https://www.linkedin.com/in/muhamad-alif-anwar/">Muhamad Alif Anwar</a></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="https://www.linkedin.com/in/muhamad-fannan-najma-falahi-4011411b4/">Muhamad Fannan Najma Falahi</a></td>
    </tr>
    <tr>
      <td></td>
      <td><a href="https://www.linkedin.com/in/fariz-ajy-putra/">Fariz Ajy Putra</a></td>
    </tr>
  </tbody>
</table>



