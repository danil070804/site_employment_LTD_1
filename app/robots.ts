export default function robots() {
  const base = process.env.AUTH_URL || "https://siteemploymentltd1-production.up.railway.app";
  return {
    rules: [{ userAgent: "*", allow: "/" }],
    sitemap: `${base}/sitemap.xml`,
  };
}
