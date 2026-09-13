<?php
$host = getenv('DB_HOST') ?: 'proxysql';
$port = getenv('DB_PORT') ?: '6033';
$db = getenv('DB_NAME') ?: 'app';
$user = getenv('DB_USER') ?: 'app';
$password = getenv('DB_PASSWORD') ?: 'app_change_me';
$status = 'offline';
$message = '';

try {
    $pdo = new PDO("mysql:host={$host};port={$port};dbname={$db}", $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_TIMEOUT => 3,
    ]);
    $status = 'online';
    $message = $pdo->query('SELECT @@hostname AS server')->fetchColumn();
} catch (Throwable $error) {
    $message = $error->getMessage();
}
?><!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Apache PHP</title></head>
<body>
<h1>Apache + PHP</h1>
<p>ProxySQL: <strong><?= htmlspecialchars($status, ENT_QUOTES, 'UTF-8') ?></strong></p>
<p>Servidor MySQL: <?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p>
</body>
</html>
