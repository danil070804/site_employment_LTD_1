/** @type {import('next').NextConfig} */
const nextConfig = {
  // В проде с Docker полезно и часто надо
  output: "standalone",

  // Опционально, но норм для продакшена
  reactStrictMode: true,

  // Чтобы картинки не ломали рендер
  images: {
    remotePatterns: [
      // Разрешаем любые HTTPS картинки (если используешь внешние аватарки/иконки)
      { protocol: "https", hostname: "**", pathname: "/**" },

      // Для локальной разработки (не влияет на Railway)
      { protocol: "http", hostname: "localhost", port: "3000", pathname: "/**" },
    ],
  },
};

export default nextConfig;
