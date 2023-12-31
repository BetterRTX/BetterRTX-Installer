"use client";
import JSZip from "jszip";
import { useState } from "react";
import {
  resourceDir,
  resolveResource,
  join,
  resolve,
  basename,
} from "@tauri-apps/api/path";
import {
  readBinaryFile,
  BaseDirectory,
  exists,
  writeBinaryFile,
} from "@tauri-apps/api/fs";
import { useModStore } from "@/store/modStore";
import type { Pack } from "@/types";
import {
  BRTX_RP_NAME,
  STUB_NAME,
  TONEMAPPING_NAME,
  BRTX_PACK_NAME,
} from "@/lib/constants";

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

  const zip = await JSZip.loadAsync(contents);
  const root = zip.folder(BRTX_RP_NAME);

  if (!root) {
    throw new Error("Root not found");
  }

  return root;
}

/**
 * Open and parse the Better RTX .mcpack file
 * @returns List of files found in .mcpack and the manifest.json contents
 */
async function openPack(): Promise<{
  files: string[];
  manifest: Manifest;
  zip: JSZip;
}> {
  const root = await unzip();
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

  return { files, manifest, zip: root };
}

async function extractPack(pack: Pack) {
  const { files, zip } = await openPack();

  await Promise.all(
    files.map(async (file) => {
      if (!file.includes(pack.name)) {
        return;
      }

      const data = await zip.file(file)?.async("uint8array");

      if (!data) {
        return;
      }

      await writeBinaryFile(await join(pack.path, await basename(file)), data, {
        dir: BaseDirectory.AppData,
      });
    }),
  );
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
      if (!isSetup) {
        await open();
      }

      return packs;
    },
    getMaterials,
    extractPack,
  };
}
