import type { Config } from "tailwindcss";
import headless from "@headlessui/tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      backgroundImage: {
        "main-background":
          "linear-gradient(180deg, rgba(0,0,0,0) 0%, #000000 100%), url('/assets/images/background.png')",
      },
      colors: {
        "minecraft-slate": {
          50: "#fcfdfd",
          100: "#e6e7e8",
          200: "#d0d1d4",
          300: "#8c8d90",
          400: "#6a6c70",
          500: "#606265",
          600: "#5a5b5c",
          700: "#48494a",
          800: "#313233",
          900: "#1e1e1f",
        },
        "minecraft-blue": {
          50: "#f0f6fe",
          100: "#dcebfd",
          200: "#c1dcfc",
          300: "#96c7fa",
          400: "#65a9f5",
          500: "#4187f0",
          600: "#2e6be5",
          700: "#2355d2",
          800: "#2345aa",
          900: "#213e87",
        },
        "minecraft-green": {
          50: "#75b75d",
          100: "#52a535",
          200: "#3c8527",
          300: "#1d4d13",
          700: "#316823",
          800: "#2a5420",
          900: "#26481f",
        },
        "minecraft-purple": {
          50: "#f4f4fe",
          100: "#eceafd",
          200: "#dbd8fc",
          300: "#c1b8fa",
          400: "#a290f5",
          500: "#8363ef",
          600: "#7345e5",
          700: "#6230d1",
          800: "#5228af",
          900: "#44238f",
          950: "#291461",
        },
        "minecraft-red": {
          50: "#fdf3f3",
          100: "#fbe5e5",
          200: "#f9cfcf",
          300: "#f4adad",
          400: "#eb7e7e",
          500: "#de5555",
          600: "#ca3636",
          700: "#aa2b2b",
          800: "#8d2727",
          900: "#762626",
          950: "#3f1010",
        },
      },
    },
  },
  plugins: [headless],
};
export default config;
