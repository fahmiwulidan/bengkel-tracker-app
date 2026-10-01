# bengkel-tracker
Bengkel Tracker's Repository with Geographic Information System and Payment Gateway Integration


## Do & Don't
1. Do: Gunakan ```.gitignore``` agar file ```.env``` tidak ter-upload.
2. Do: Selalu ```git pull``` sebelum membuat branch baru.
3. Don't: Melakukan ```git push --force``` karena bisa menghapus kerjaan teman.


## Workflow Harian (Lakukan ini setiap kali ingin melanjutkan progress)
### 1. Sinkronisasi Awal
#### Pindah ke branch develop
```git checkout develop```
#### Ambil kode terbaru dari server
```git pull origin develop```

### 2. Membuat Branch Baru
#### Buat dan pindah ke branch baru
- Opsi: feat, fix, docs, ui (Gunakan huruf kecil semua)
- Feature: ```git checkout -b feat/nama-fitur```
  - Contoh: ```feat/chat-realtime```, ```feat/tracking-mekanik```
- Fix bug: ```git checkout -b fix/masalah```
  - Contoh: ```fix/kalkulasi-biaya```, ```fix/login-error```
- Dokumentasi: ```git checkout -b docs/nama-dokumen```
  - Contoh: ```docs/readme-install```, ```docs/api-spec```
- UI:  ```git checkout -b ui/nama-halaman```
  - Contoh: ```ui/dashboard-admin```, ```ui/sidebar-mekanik```

### 3. Commit Perubahan
#### Cek file yang berubah
```git status```
#### Tambahkan file ke area staging
```git add .```
#### Simpan dengan pesan yang jelas
```git commit -m "feat: menambah integrasi websocket Reverb untuk tracking"```

### 4. Push ke Github
#### Push branch ke origin
```git push origin feat/nama-fitur```

### 5. Membuat Pull Request
#### a. Buka repositori di GitHub.
#### b. Klik tombol Compare & pull request.
#### c. Pilih base: *develop* <- *compare: feat/nama-fitur*.
#### d. Tulis deskripsi singkat apa yang kamu ubah.
#### e. Review code oleh project manager.

### 6. Pembersihan (Setelah Merge)
#### Kembali ke branch develop
```git checkout develop```
#### Pull dari branch develop
```git pull origin develop```
#### Hapus branch feature/fix/docs/ui yang sebelumnya digunakan
```git branch -d feat/nama-fitur```


## Jika Terjadi Conflict (Dilakukan oleh Project Manager)
### 1. Buka file yang bermasalah di VS Code.
### 2. Pilih perubahan yang ingin diambil (Accept Current / Incoming).
### 3. Simpan file, lalu: *git add .* -> *git commit -m "fix: resolve merge conflict"* -> *git push*.
