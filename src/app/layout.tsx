import cx from "clsx";
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import Navigation from "@/components/navigation";
import "@/lib/i18n";
import "./globals.css";
const inter = Inter({
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "BetterRTX Installer",
  description: "Customize and install BetterRTX Minecraft mod",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={cx(inter.className, "relative", "bg-main-background")}>
        <div className="z-10 flex w-full flex-col sm:fixed sm:flex-row">
          <Navigation />
          <div className="min-w-screen-sm flex h-screen min-h-screen w-full max-w-screen-2xl flex-grow flex-col overflow-y-auto p-2">
            {children}
          </div>
        </div>
      </body>
    </html>
  );
}
