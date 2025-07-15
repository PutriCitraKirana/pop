vcl 4.0;

import std;

backend default {
    .host = "209.38.141.100";  # Ganti dengan alamat IP backend Anda
    .port = "443";             # Ganti dengan port backend Anda
}

sub vcl_recv {
    # Mengatur cache untuk semua permintaan GET dan HEAD
    if (req.method == "GET" || req.method == "HEAD") {
        return (hash);
    }

    # Mengabaikan permintaan POST dan PUT
    return (pass);
}

sub vcl_backend_response {
    # Mengatur waktu cache untuk respons dari backend
    if (beresp.status == 200) {
        set beresp.ttl = 5m;  # Cache untuk 5 menit
        set beresp.grace = 1h; # Grace period untuk 1 jam
        set beresp.keep = 1h;  # Menjaga objek dalam cache selama 1 jam
    }

    # Mengatur cache untuk file kecil
    if (beresp.http.Content-Length <= 1024) {  # Jika ukuran file <= 1 KB
        set beresp.ttl = 10m;  # Cache untuk 10 menit
    }
}

sub vcl_deliver {
    # Menambahkan header untuk debugging
    set resp.http.X-Cache = (beresp.status == 200) ? "HIT" : "MISS";
    set resp.http.X-Cache-TTL = beresp.ttl;  # Menampilkan TTL cache
}

sub vcl_backend_error {
    # Mengatur respons ketika terjadi kesalahan pada backend
    return (retry);
}