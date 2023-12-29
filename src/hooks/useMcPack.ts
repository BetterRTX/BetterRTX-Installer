"use client";
import JSZip from "jszip";
import { readBinaryFile, BaseDirectory } from "@tauri-apps/api/fs";

async function openPack() {
  const contents = await readBinaryFile("BetterRTX.mcpack", {
    dir: BaseDirectory.Resource,
  });

  const zip = await JSZip.loadAsync(contents);
  const root = zip.folder("BetterRTX Resource Pack")!;
  const subpacks = root.folder("subpacks")!;

  const files: string[] = [];

  subpacks.forEach(async (relativePath, file) => {
    if (file.dir) {
      return;
    }

    // const contents = await file.async("string");
    files.push(file.name);
  });

  return files;
}

export function useMcPack() {
  return {
    openPack,
  };
}
