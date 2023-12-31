"use client";
import cx from "clsx";
import { usePathname } from "next/navigation";
import { Link } from "@/components/link";
import { useTranslation } from "react-i18next";

function NavList() {
  const pathname = usePathname();
  const { t } = useTranslation();

  return (
    <>
      <Link
        className={cx(
          "font-bold hover:underline",
          pathname === "/setup" && "underline",
        )}
        href="/setup"
      >
        {t("navigation.setup")}
      </Link>
      <Link
        className={cx(
          "font-bold hover:underline",
          pathname === "/mod" && "underline",
        )}
        href="/mod"
      >
        {t("navigation.mod")}
      </Link>
    </>
  );
}

export default function Navigation() {
  return (
    <nav className="flex h-16 w-full flex-row items-center justify-between border-b border-white/10 bg-minecraft-slate-900/75 text-white shadow-md backdrop-blur-md">
      <div className="container mx-auto flex px-2">
        <div className="flex flex-shrink flex-row items-center">
          <svg
            className="m-2 ml-0 h-8 w-full min-w-32 fill-white/5 transition-all duration-100 ease-out hover:fill-white/50 sm:h-12"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 975.14 191.5"
          >
            <path
              className="fill-white dark:fill-gray-900"
              d="M65.06 138.85V54.37h34.4c9.25 0 16.55 2.11 21.9 6.34 5.35 4.22 8.03 9.92 8.03 17.08v2.05c0 3.22-.83 6.09-2.47 8.63-1.65 2.53-3.96 4.65-6.94 6.34 4.18 1.69 7.4 4.06 9.65 7.12 2.25 3.06 3.38 6.72 3.38 10.98v2.05c0 7.48-2.64 13.34-7.9 17.56s-12.61 6.34-22.02 6.34H65.07zm17.62-50.08h16.29c8.53 0 12.79-2.9 12.79-8.69v-2.05c0-2.73-1.11-4.87-3.32-6.4-2.21-1.53-5.37-2.29-9.47-2.29H82.68v19.43zm0 35.12h19.91c8.53 0 12.79-2.97 12.79-8.93v-2.29c0-2.9-1.11-5.15-3.32-6.76-2.21-1.61-5.37-2.41-9.47-2.41H82.68v20.4zm88.58 16.65c-9.49 0-16.86-2.69-22.08-8.09-5.23-5.39-7.84-12.99-7.84-22.81v-3.62c0-9.81 2.66-17.46 7.97-22.93 5.31-5.47 12.63-8.21 21.96-8.21h.97c8.85 0 15.75 2.68 20.7 8.03 4.95 5.35 7.42 12.73 7.42 22.14v7.6H158c.56 9.58 4.99 14.36 13.27 14.36h1.69c6.35 0 10.82-2.13 13.39-6.4l12.19 8.09c-2.25 3.7-5.61 6.6-10.08 8.69s-9.59 3.14-15.39 3.14h-1.81zm-13.15-39.22h25.83v-.36c0-8.37-3.9-12.55-11.71-12.55h-.97c-7.72 0-12.11 4.3-13.15 12.91zm85.32 38.25c-8.61 0-14.71-1.85-18.28-5.55-3.58-3.7-5.37-9.21-5.37-16.53V90.7h-13.03V76.58h13.03V58.84h16.9v17.74h19.19l-2.05 14.12h-17.14v26.19c0 2.98.74 5.13 2.23 6.46s3.52 1.99 6.1 1.99h10.86v14.24h-12.43zm54.07 0c-8.61 0-14.71-1.85-18.28-5.55-3.58-3.7-5.37-9.21-5.37-16.53V90.7h-13.03V76.58h13.03V58.84h16.9v17.74h19.19l-2.05 14.12h-17.14v26.19c0 2.98.74 5.13 2.23 6.46s3.52 1.99 6.1 1.99h10.86v14.24h-12.43zm50.8.97c-9.49 0-16.86-2.69-22.08-8.09-5.23-5.39-7.84-12.99-7.84-22.81v-3.62c0-9.81 2.66-17.46 7.97-22.93 5.31-5.47 12.63-8.21 21.96-8.21h.97c8.85 0 15.75 2.68 20.7 8.03 4.95 5.35 7.42 12.73 7.42 22.14v7.6h-42.36c.56 9.58 4.99 14.36 13.27 14.36H350c6.35 0 10.82-2.13 13.39-6.4l12.19 8.09c-2.25 3.7-5.61 6.6-10.08 8.69s-9.59 3.14-15.39 3.14h-1.81zm-13.15-39.22h25.83v-.36c0-8.37-3.9-12.55-11.71-12.55h-.97c-7.72 0-12.11 4.3-13.15 12.91zm54.18 37.53V76.58h14.72V87.2c1.69-3.62 3.82-6.41 6.4-8.39 2.57-1.97 6.07-2.96 10.5-2.96h6.64v15.57h-6.03c-2.41 0-4.79.48-7.12 1.45s-4.28 2.64-5.85 5.01c-1.57 2.37-2.35 5.65-2.35 9.84v31.14h-16.9zm51.65 0V54.37h31.98c9.81 0 17.6 2.29 23.35 6.88s8.63 10.94 8.63 19.07v2.29c0 5.71-1.39 10.54-4.16 14.48-2.78 3.94-6.66 6.92-11.65 8.93l18.46 32.83H488.4l-16.65-30.17H458.6v30.17h-17.62zm17.62-45.38h13.88c4.26 0 7.8-.8 10.62-2.41 2.82-1.61 4.22-4.3 4.22-8.09v-3.02c0-3.62-1.41-6.26-4.22-7.9-2.82-1.65-6.36-2.47-10.62-2.47H458.6v23.9zm78.33 45.38V69.58h-25.34V54.37h68.31v15.21h-25.35v69.27h-17.62zm106.07 0l-19.19-29.33-19.19 29.33h-20.4l29.09-42.84-28.12-41.64h20.88l18.22 27.88 18.22-27.88h20.39l-28.12 41.64 29.09 42.84h-20.88z"
            ></path>
            <path d="M966.32 0H8.82C3.95 0 0 3.95 0 8.82v173.86c0 4.87 3.95 8.82 8.82 8.82h957.5c4.87 0 8.82-3.95 8.82-8.82V8.82c0-4.87-3.95-8.82-8.82-8.82zM720.65 173.82c0 4.89-3.97 8.86-8.86 8.86H18.94c-4.89 0-8.86-3.97-8.86-8.86V17.68c0-4.89 3.97-8.86 8.86-8.86h692.85c4.89 0 8.86 3.97 8.86 8.86v156.14zM845.33 99.5c0 8.47-1.54 15.79-4.62 21.94-3.08 6.16-7.51 10.91-13.3 14.27-5.8 3.36-12.77 5.03-20.92 5.03h-1.2c-8.15 0-15.13-1.68-20.92-5.03-5.8-3.36-10.23-8.11-13.31-14.27-3.08-6.15-4.62-13.47-4.62-21.94v-4.79c0-8.47 1.54-15.78 4.62-21.94 3.08-6.15 7.51-10.91 13.31-14.27 5.79-3.36 12.77-5.04 20.92-5.04h1.2c8.15 0 15.12 1.68 20.92 5.04 5.79 3.36 10.23 8.11 13.3 14.27 3.08 6.15 4.62 13.47 4.62 21.94v4.79zm71.57 39.56h-16.78v-36.08c0-4.15-.86-7.37-2.58-9.65-1.72-2.28-4.42-3.42-8.09-3.42h-.96c-2 0-3.94.52-5.81 1.56-1.88 1.04-3.44 2.64-4.68 4.79-1.24 2.16-1.86 5-1.86 8.51v34.29h-16.78V77.2h14.62v7.67c2.08-2.96 4.74-5.25 7.97-6.89 3.24-1.64 6.85-2.46 10.85-2.46h1.2c7.03 0 12.61 2.18 16.72 6.53 4.12 4.36 6.17 10.57 6.17 18.64v38.36z"></path>
            <path d="M806.36 68.81h-.96c-6.56 0-11.77 2.12-15.64 6.35-3.88 4.24-5.81 10.63-5.81 19.18v5.51c0 8.55 1.94 14.95 5.81 19.18 3.88 4.24 9.09 6.35 15.64 6.35h.96c6.55 0 11.77-2.12 15.65-6.35 3.88-4.23 5.81-10.63 5.81-19.18v-5.51c0-8.55-1.94-14.94-5.81-19.18-3.88-4.23-9.09-6.35-15.65-6.35z"></path>
          </svg>
        </div>
        <div className="flex flex-1 items-center justify-end space-x-2">
          <NavList />
        </div>
      </div>
    </nav>
  );
}
