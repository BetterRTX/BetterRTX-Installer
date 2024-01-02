"use client";
import { useState } from "react";
import {
  join,
  basename,
  appLocalDataDir,
  resourceDir,
} from "@tauri-apps/api/path";
import {
  readBinaryFile,
  BaseDirectory,
  exists,
  writeBinaryFile,
  createDir,
} from "@tauri-apps/api/fs";
import { useModStore } from "@/store/modStore";
import type { Pack } from "@/types";
import {
  BRTX_RP_NAME,
  STUB_NAME,
  TONEMAPPING_NAME,
  BRTX_PACK_NAME,
} from "@/lib/constants";
import JSZip, { file } from "jszip";

type Manifest = Record<string, unknown> & {
  subpacks: Record<string, string | number>[];
};

async function getMaterials(pack: Pack): Promise<string[]> {
  const materialsDir = `${pack.path}/renderer/materials`;

  return [
    `${materialsDir}/${STUB_NAME}`,
    `${materialsDir}/${TONEMAPPING_NAME}`,
  ];
}

async function unzip() {
  if (!(await exists(BRTX_PACK_NAME, { dir: BaseDirectory.Resource }))) {
    throw new Error("Resource pack not found");
  }

  const contents = await readBinaryFile(BRTX_PACK_NAME, {
    dir: BaseDirectory.Resource,
  });

  let zip: JSZip | undefined = await JSZip.loadAsync(contents);
  const root = zip.folder(BRTX_RP_NAME);

  if (!root) {
    throw new Error("Root not found");
  }

  return {
    root,
    unload() {
      zip = undefined;
    },
  };
}

/**
 * Open and parse the Better RTX .mcpack file
 * @returns List of files found in .mcpack and the manifest.json contents
 */
async function openPack(): Promise<{
  files: string[];
  manifest: Manifest;
  zip: JSZip;
  unload: () => void;
}> {
  const { root, unload } = await unzip();
  const subpacks = root.folder("subpacks")!;

  const manifest = JSON.parse(await root.file("manifest.json")!.async("text"));

  const files: string[] = [];

  subpacks.forEach((_relativePath, file) => {
    if (file.dir) {
      return;
    }

    // const contents = await file.async("string");
    files.push(file.name);
  });

  return { files, manifest, zip: root, unload };
}

export function useExtractPack(pack: Pack) {
  const [isExtracting, setIsExtracting] = useState(false);
  const [files, setFiles] = useState<string[]>([]);
  const [error, setError] = useState<Error | null>(null);
  const [progress, setProgress] = useState(0);
  const [packFiles, setPackFiles] = useState<string[]>([]);
  const [packDirectory, setPackDirectory] = useState<string>("");

  return {
    isExtracting,
    progress,
    files,
    error,
    packDirectory,
    async getData() {
      const { zip, files: fileList, unload } = await openPack();

      // Pack directory under the installer's app data directory.
      // Needs to be moved to the sideloaded instance's directory
      const packDir = await join(
        await appLocalDataDir(),
        BRTX_RP_NAME,
        "subpacks",
      );

      await createDir(packDir, { recursive: true });

      setPackDirectory(packDir);

      const packFiles = fileList.filter((f) => f.includes(pack.name));

      setPackFiles(packFiles);

      try {
        setIsExtracting(true);
        const res = await Promise.all(
          packFiles.map(async (file) => {
            const zipFileName = file.replace(`${BRTX_RP_NAME}/`, "");
            const zipFile = zip.file(zipFileName);

            if (!zipFile) {
              console.warn(`File ${zipFileName} not found`);
              return null;
            }

            const data = await zipFile?.async("uint8array");

            if (!data) {
              return null;
            }

            const destDir = await join(
              packDir,
              pack.name,
              "renderer",
              "materials",
            );

            await createDir(destDir, { recursive: true });

            const dest = await join(destDir, await basename(file));

            await writeBinaryFile(dest, data);

            setProgress((p) => {
              const next = p + 1;
              if (next === packFiles.length) {
                setIsExtracting(false);
              }

              return next;
            });

            return file;
          }),
        );

        return res.filter((file) => file !== null) as string[];
      } catch (e) {
        setError(e as Error);
      } finally {
        setIsExtracting(false);
        unload();
      }

      return [];
    },
  };
}

export function useMcPack() {
  const [isSetup, setIsSetup] = useState(false);
  const { addPack, packs } = useModStore();

  const open = async () => {
    const { files, manifest } = await openPack();
    await Promise.all(
      manifest.subpacks.map(
        async (subpack: Record<string, string | number>) => {
          const pack: Pack = {
            title: subpack.description as string,
            name: subpack.name as string,
            uuid: subpack.uuid as string,
            path: await join(
              await resourceDir(),
              BRTX_RP_NAME,
              "subpacks",
              subpack.name as string,
            ),
          };
          addPack(pack);
        },
      ),
    );

    setIsSetup(true);

    return { files, manifest };
  };

  return {
    isSetup,
    open,
    async getPacks() {
      if (!packs.length && !isSetup) {
        await open();
      }

      return packs;
    },
    getMaterials,
  };
}
