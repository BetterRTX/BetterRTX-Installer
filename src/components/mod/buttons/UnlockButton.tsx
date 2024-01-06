"use client";
import { useState, useCallback, useContext, useEffect } from "react";
import clsx from "clsx";
import { useTranslation } from "react-i18next";
import { Menu, Transition, Dialog, Description } from "@headlessui/react";
import { readDir, type FileEntry } from "@tauri-apps/api/fs";
import {
  LockClosedIcon,
  LockOpen2Icon,
  LockOpen1Icon,
  ReloadIcon,
  ArrowRightIcon,
  CheckIcon,
  Cross1Icon,
} from "@radix-ui/react-icons";
import { useUnlock, useMinecraftProcess } from "@/hooks";
import { RP_DIR } from "@/lib/constants";
import { isValidMaterial } from "@/lib";
import { PackContext } from "@/context/PackContext";

function UnlockerEntryMenu({
  onInstall,
  loading,
}: {
  onInstall: (location: string) => void;
  loading: boolean;
}) {
  const { t } = useTranslation();
  const { locations, refreshLocations, getInstanceName } =
    useMinecraftProcess();

  return (
    <div className="relative">
      <Menu>
        {({ open }) => (
          <>
            <Menu.Button
              className={clsx(
                open
                  ? "rounded-b-none border-minecraft-purple-400 border-b-minecraft-purple-900 bg-minecraft-purple-700/60"
                  : "bg-minecraft-purple-700/25",
                loading && "animate-pulse",
                "btn inline-flex h-12 w-12 justify-center rounded-lg py-0 shadow-md outline-none hover:bg-minecraft-purple-700 focus:bg-minecraft-purple-500/80 focus:outline-none active:bg-minecraft-purple-800/75 active:outline-none",
              )}
            >
              <LockOpen1Icon className="block h-5 w-5 flex-shrink fill-gray-100" />
            </Menu.Button>
            <Transition
              enter="transition duration-100 ease-out"
              enterFrom="opacity-0"
              enterTo=" opacity-100"
              leave="transition duration-75 ease-out"
              leaveFrom=" opacity-100"
              leaveTo="opacity-0"
              as="div"
            >
              <Menu.Items className="absolute right-0 top-12 z-20 mt-0 min-w-24 divide-y divide-minecraft-slate-400/75 rounded-b-md rounded-tl-md border border-minecraft-slate-800/90 bg-minecraft-slate-700/80 shadow-xl backdrop-blur-sm">
                <div className="cursor-default overflow-hidden truncate whitespace-nowrap text-nowrap rounded-tl-md border border-minecraft-slate-300/50 border-b-minecraft-slate-700/50 bg-minecraft-slate-800/60 px-4 py-2 text-xs font-medium uppercase text-gray-200/80">
                  {t("mod.installUnlockerInstance")}
                </div>
                {Object.entries(locations).map(([instance, location]) => (
                  <Menu.Item key={location}>
                    <button
                      className="group inline-flex w-full items-center border border-minecraft-slate-400/50 border-x-minecraft-slate-300/50 text-left text-sm text-gray-50 backdrop-blur-md transition-colors duration-200 ease-out last:rounded-b-md last:border-b last:border-b-minecraft-slate-200/50 hover:bg-minecraft-slate-400/75 hover:text-gray-100"
                      onClick={() => onInstall(location)}
                    >
                      <ArrowRightIcon className="ml-2 h-4 w-4 flex-shrink fill-gray-100 opacity-0 transition-opacity duration-150 ease-out group-hover:opacity-100" />
                      <span className="h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-slate-700/50 px-4 py-2 font-medium leading-tight group-last:border-minecraft-slate-500/50 group-hover:text-gray-200/90 group-focus:text-gray-100">
                        {getInstanceName(instance)}
                      </span>
                    </button>
                  </Menu.Item>
                ))}
                <Menu.Item>
                  <button
                    className="group inline-flex w-full items-center border border-minecraft-slate-400/50 border-x-minecraft-slate-300/50 text-left text-sm backdrop-blur-md transition-colors duration-200 ease-out last:rounded-b-md last:border-b last:border-b-minecraft-slate-200/50 hover:bg-minecraft-slate-400/75 hover:text-gray-100"
                    type="button"
                    onClick={refreshLocations}
                  >
                    <ReloadIcon className="ml-2 h-4 w-4 flex-shrink fill-gray-100/50 group-active:animate-spin" />
                    <span className="h-full flex-grow whitespace-nowrap text-nowrap border-b border-b-minecraft-slate-700/50 px-4 py-2 text-xs leading-tight text-gray-50/90 group-last:border-minecraft-slate-500/50 group-hover:text-gray-200/90 group-focus:text-gray-100">
                      {t("mod.refreshLocations")}
                    </span>
                  </button>
                </Menu.Item>
              </Menu.Items>
            </Transition>
          </>
        )}
      </Menu>
    </div>
  );
}

function processEntries(entries: FileEntry[], files: string[] = []) {
  for (const entry of entries) {
    if (entry.children) {
      processEntries(entry.children, files);
    }

    if (isValidMaterial(entry.path)) {
      files.push(entry.path);
    }
  }

  return files;
}

function UnlockerModal({
  src,
  dest,
  onClose,
}: {
  src: string;
  dest: string;
  onClose: () => void;
}) {
  const [unlocked, setUnlocked] = useState<string[]>([]);
  const [files, setFiles] = useState<string[]>([]);
  const { t } = useTranslation();
  const { error, result, unlockFile } = useUnlock();

  const fileBasename = (file: string) => {
    const regex = new RegExp("[^\\\\/]*$");
    return file.match(regex)?.[0] ?? "";
  };

  useEffect(() => {
    readDir(src, {
      recursive: true,
    }).then((entries) => {
      setFiles(processEntries(entries));
    });
  }, [src]);

  const handleUnlock = async () => {
    console.log(src, dest);
    try {
      const res = await Promise.all(
        files.map(async (file) =>
          (await unlockFile(file, dest)) ? file : null,
        ),
      );

      setUnlocked(
        res
          .filter((file) => file !== null)
          .map((file) => file as string)
          .map(fileBasename),
      );
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <Dialog
      open
      {...{ onClose }}
      className="fixed inset-0 top-1/2 z-40 mx-auto flex max-h-72 min-h-56 max-w-screen-sm -translate-y-1/2 flex-col overflow-hidden whitespace-nowrap rounded-lg border border-minecraft-slate-500 bg-minecraft-slate-600/60 shadow-2xl backdrop-blur-xl"
    >
      <Dialog.Panel className="flex flex-grow flex-col rounded-lg border border-minecraft-slate-100/50">
        <Dialog.Title className="flex flex-shrink flex-row items-center justify-between rounded-t-lg border border-x-minecraft-slate-400/50 border-b-minecraft-slate-200/50 border-t-minecraft-slate-300/50 bg-minecraft-slate-400/50 px-3 py-2 text-lg font-semibold text-gray-50/50">
          <h3 className="capitalize text-gray-50 drop-shadow">
            {t("mod.unlockerModal.title")}
          </h3>
          <Cross1Icon
            className="h-5 w-5 cursor-pointer text-gray-400 drop-shadow-sm transition-colors duration-200 ease-out hover:text-gray-200 active:text-gray-100"
            onClick={onClose}
          />
        </Dialog.Title>
        <Description className="flex flex-shrink flex-col border-y border-b-minecraft-slate-500/50 border-t-minecraft-slate-400 bg-minecraft-slate-600/75 px-3 py-1 text-sm leading-relaxed text-gray-200">
          {t("mod.unlockerModal.description")}
          {error && <p className="error-message">{error.message}</p>}
        </Description>
        <div className="h-24 flex-grow divide-y divide-minecraft-slate-400 overflow-y-auto border-t border-t-minecraft-slate-100/50 bg-gradient-to-b from-minecraft-slate-800/90 to-minecraft-slate-900/90">
          {result && (
            <div className="flex flex-grow flex-col divide-y divide-gray-500/50">
              {files.map((file) => (
                <div
                  key={file}
                  className="flex items-center justify-start space-x-2 px-2 py-3 text-xs leading-relaxed text-gray-100"
                >
                  {unlocked.includes(file) ? (
                    <LockOpen2Icon className="h-4 w-4 text-green-200/90" />
                  ) : (
                    <LockClosedIcon className="h-4 w-4 text-gray-400" />
                  )}
                  <span className="flex-grow truncate" title={file}>
                    {fileBasename(file)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="mt-auto flex flex-shrink space-x-2 rounded-b-lg border border-x-minecraft-slate-400/50 border-b-minecraft-slate-500/50 border-t-minecraft-slate-100/50 bg-minecraft-slate-700/75 p-2 sm:justify-between">
          <button
            className="btn btn--secondary my-1"
            type="button"
            onClick={onClose}
          >
            {t("mod.unlockerModal.cancel")}
          </button>
          <button
            className="btn btn--lg btn--primary"
            type="button"
            onClick={handleUnlock}
            disabled={unlocked.length > 0}
          >
            {t("mod.unlockerModal.unlock")}
          </button>
        </div>
      </Dialog.Panel>
      <Dialog.Backdrop
        className="fixed inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
    </Dialog>
  );
}

export default function UnlockButton() {
  const pack = useContext(PackContext);
  const [dest, setDest] = useState<string>("");
  const [src, setSrc] = useState<string>("");

  // const {
  //   files,
  //   getData,
  //   isExtracting,
  //   progress,
  //   error: extractionError,
  //   packDirectory,
  // } = useExtractPack(pack);

  const handleInstall = useCallback(
    async (location: string) => {
      const { join, appLocalDataDir } = await import("@tauri-apps/api/path");
      setSrc(await join(await appLocalDataDir(), RP_DIR, pack.uuid));
      setDest(await join(location, "data", "renderer", "materials"));
    },
    [pack.uuid],
  );

  return (
    <>
      {dest.length > 0 && (
        <UnlockerModal
          onClose={() => {
            setDest("");
          }}
          {...{ dest, src }}
        />
      )}
      <UnlockerEntryMenu
        onInstall={(location) => handleInstall(location)}
        loading={false}
      />
    </>
  );
}
