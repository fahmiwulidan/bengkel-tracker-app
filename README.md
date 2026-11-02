<div align="center">

  <h1>Bengkel Tracker App</h1>
  <p><b>Platform Sistem Informasi Geografis & Manajemen Pelacakan Layanan Bengkel</b></p>

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](./LICENSE)

  <br />

  [Laporkan Bug](https://github.com/fahmiwulidan/bengkel-tracker-app/issues) •
  [Minta Fitur](https://github.com/fahmiwulidan/bengkel-tracker-app/issues)

</div>

---

## Ringkasan Proyek

**Bengkel Tracker App** adalah aplikasi *mobile cross-platform* yang dirancang untuk mempermudah pelacakan status perbaikan kendaraan, pemantauan posisi mekanik secara *real-time*, serta pengelolaan transaksi perbengkelan secara terintegrasi. Aplikasi ini memadukan teknologi Sistem Informasi Geografis (SIG/GIS) dan gerbang pembayaran (*payment gateway*) untuk memberikan pengalaman layanan yang cepat, transparan, dan terpercaya.

> [!NOTE]
> Aplikasi ini dikembangkan menggunakan framework **Flutter** berbasis bahasa pemrograman **Dart** yang mendukung deployment multi-platform (Android, iOS, Web, & Desktop).

---

## Teknologi Utama

| Layer | Teknologi | Deskripsi |
| :--- | :--- | :--- |
| **Framework** | Flutter | Development framework multi-platform untuk antarmuka pengguna yang responsif |
| **Language** | Dart | Bahasa pemrograman utama logika aplikasi & state management |
| **GIS & Tracking** | Google Maps API / Reverb WebSocket | Fitur pelacakan lokasi mekanik & pemetaan posisi secara *real-time* |
| **Payment Gateway** | Payment API Integration | Pemrosesan transaksi & pembayaran digital yang aman |

---

## Fitur Unggulan

- **Pelacakan Posisi Mekanik (Real-Time GIS)** — Pemantauan lokasi mekanik dan kendaraan secara presisi berbasis peta interaktif.
- **Integrasi Payment Gateway** — Kemudahan pembayaran tagihan servis kendaraan melalui berbagai metode pembayaran digital.
- **Komunikasi Real-Time (WebSocket/Reverb)** — Fitur pesan/obrolan langsung dan pembaruan status perbaikan secara *real-time*.
- **Multi-Platform Support** — Kompatibilitas penuh untuk dijalankan pada perangkat Android, iOS, maupun Web.

---

## Aturan Pengerjaan Proyek (Do & Don't)

- **Gunakan `.gitignore`** — Pastikan berkas sensitif seperti `.env` tidak terunggah ke repositori.
- **Selalu Sinkronisasi** — Lakukan `git pull` sebelum membuat *branch* baru.
- **Hindari Forced Push** — Dilarang melakukan `git push --force` karena dapat menimpa dan menghapus riwayat pekerjaan anggota tim.

---

## Alur Kerja Pengembangan (Git Workflow)

### 1. Sinkronisasi Awal
Pindah ke branch `develop` dan ambil pembaruan kode terbaru dari repositori server:
```bash
git checkout develop
git pull origin develop
```

---

<div align="center">
  <sub>Dikembangkan dengan ❤️ oleh <a href="https://github.com/fahmiwulidan">Fahmi Wulidan</a></sub>
</div>
