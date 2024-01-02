"use client";
import { join, basename } from "@tauri-apps/api/path";
import {
  copyFile,
  removeFile,
  exists,
  readBinaryFile,
} from "@tauri-apps/api/fs";
import {
  DownloadIcon,
  LockOpen1Icon,
  CheckIcon,
  UpdateIcon,
  ExclamationTriangleIcon,
  Cross2Icon,
} from "@radix-ui/react-icons";
import { useTranslation } from "react-i18next";
import { BRTX_RP_NAME } from "@/lib/constants";

export default function PackEntryError({
  packFiles,
  packDirectory,
  dismiss,
}: {
  packFiles: string[];
  packDirectory: string;
  dismiss: () => void;
}) {
  const { t } = useTranslation();

  const handleDownload = async (file: string) => {
    const filePath = await join(
      packDirectory,
      file
        .replace(`${BRTX_RP_NAME}/subpacks`, "")
        .replace(`${BRTX_RP_NAME}\\subpacks`, ""),
    );
    // Create blob from file and automatically download it
    const blob = new Blob([await readBinaryFile(filePath)]);
    const url = URL.createObjectURL(blob);

    // Create a link element
    const link = document.createElement("a");
    // Set the file name

    link.href = url;
    link.download = await basename(filePath);
    link.click();

    // Remove the link element
    link.remove();

    // Revoke the blob url
    URL.revokeObjectURL(url);
  };

  return (
    <div className="absolute right-0 top-0 z-40 mt-0 flex min-w-24 -translate-x-1/2 -translate-y-1 flex-col divide-y divide-minecraft-red-400/75 overflow-hidden rounded-md border border-minecraft-red-800/90 bg-minecraft-red-700/60 shadow-2xl shadow-minecraft-red-900/45 backdrop-blur-sm">
      <div className="relative flex w-full flex-shrink cursor-default flex-col overflow-hidden truncate whitespace-nowrap text-nowrap rounded-t-md border border-minecraft-red-300/50 border-b-minecraft-red-800/50 bg-minecraft-red-800/40 px-4 py-2">
        <h6 className="text-sm font-medium uppercase text-red-200/80">
          {t("mod.errorCopyingSideloadPack")}
        </h6>
        <p className="text-xs text-red-300/75">
          {t("mod.errorCopyingSideloadPackDescription")}
        </p>

        <button
          className="group cursor-pointer"
          type="button"
          onClick={() => dismiss()}
        >
          <Cross2Icon className="absolute right-2 top-2 h-5 w-5 text-red-200/50 group-hover:text-red-100/75" />
        </button>
      </div>
      <div className="max-h-52 overflow-y-auto">
        {packFiles.map((file) => (
          <button
            className="group flex w-full flex-grow cursor-pointer items-stretch truncate border border-minecraft-red-400/50 border-x-minecraft-red-300/50 border-b-minecraft-red-900/40 text-left text-sm text-red-50 backdrop-blur-md transition-colors duration-200 ease-out first:border-t-0 last:rounded-bl-md last:border-b last:border-b-minecraft-red-200/50 hover:bg-minecraft-red-400/60 hover:text-red-100"
            key={file}
            type="button"
            onClick={() => {
              handleDownload(file).then(() => {
                console.log("Downloaded", file);
              });
            }}
          >
            <span className="block h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-red-700/50 px-4 py-2 text-xs group-last:rounded-r-none group-last:border-minecraft-red-500/50 group-hover:text-red-200/90 group-focus:text-red-100">
              {file.split("/")?.pop()}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}
