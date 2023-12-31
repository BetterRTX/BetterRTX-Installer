"use client";
import "@/lib/i18n";
import cx from "clsx";
import { Inter } from "next/font/google";
import Navigation from "@/components/navigation";
import "./globals.css";
const inter = Inter({
  subsets: ["latin"],
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={cx(inter.className, "relative", "bg-main-background")}>
        <div className="z-10 flex w-full flex-col items-start justify-start sm:fixed">
          <Navigation />
          <div className="min-w-screen-sm flex h-screen min-h-screen w-full flex-grow flex-col overflow-y-auto">
            {children}
          </div>
        </div>
      </body>
    </html>
  );
}
