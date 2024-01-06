"use client";
import clsx from "clsx";
import { useState, useEffect } from "react";
import { Disclosure } from "@headlessui/react";
import { listen, TauriEvent, type Event } from "@tauri-apps/api/event";
import { PlusIcon, ReloadIcon } from "@radix-ui/react-icons";
import { useExtractUpload } from "@/hooks";
import { useModStore } from "@/store";
import { useTranslation } from "react-i18next";
import FileName from "@/components/FileName";
import { isMcPack, isValidMaterial } from "@/lib";

interface PackUploadEntryProps {
  src: string;
}

function PackUploadEntry({ src }: PackUploadEntryProps) {
  const [files, setFiles] = useState<string[]>([]);
  const { error, isExtracting, getData, packDirectory, uuid } =
    useExtractUpload(src);
  const { addPack } = useModStore();
  const { t } = useTranslation();
  const [newPackName, setNewPackName] = useState("");

  useEffect(() => {
    if (files.length > 0 || isExtracting) {
      return;
    }
    getData().then((f) => {
      setFiles(f ?? []);
    });
  }, [getData, files, isExtracting]);

  return (
    <div className="card">
      {files.length > 0 && (
        <div className="flex">
          <input
            className="input"
            onChange={(e) => {
              setNewPackName(e.target.value);
            }}
            placeholder={t("mod.name")}
            type="text"
            value={newPackName}
          />
          <button
            className="btn"
            onClick={() => {
              addPack({
                name: newPackName.replace(/[^\w\s]/gi, "").replace(/\s+/g, "-"),
                path: packDirectory,
                uuid,
                title: newPackName,
              });
            }}
            type="button"
            disabled={
              newPackName.length === 0 ||
              isExtracting ||
              !files.some(isValidMaterial)
            }
          >
            {t("mod.upload")}
          </button>
        </div>
      )}
      {error && <p className="error-message">{t(error.message)}</p>}
      {isExtracting && <ReloadIcon className="h-8 w-8 animate-spin" />}
      <Disclosure>
        <Disclosure.Button>{t("mod.uploadContents")}</Disclosure.Button>
        <Disclosure.Panel>
          <h5 className="text-sm font-medium text-gray-200/75">{uuid}</h5>
          {files.map((file) => (
            <FileName key={file} {...{ file }} />
          ))}
          {packDirectory && (
            <div className="w-full overflow-hidden truncate border-t text-xs text-gray-50/50">
              <p>{packDirectory}</p>
            </div>
          )}
        </Disclosure.Panel>
      </Disclosure>
    </div>
  );
}

export default function PackUpload() {
  const [fileDropEnabled, setFileDropEnabled] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [fileDropped, setFileDropped] = useState(false);
  const [fileList, setFileList] = useState<string[]>([]);

  useEffect(() => {
    const unlisteners: (() => void)[] = [];

    listen(TauriEvent.WINDOW_FILE_DROP_HOVER, (event: Event<string[]>) => {
      const payloadFiles = event.payload.filter(isMcPack);

      if (payloadFiles.length === 0) {
        return;
      }

      setIsListening(true);
      setFileList([]);
    }).then((unlisten) => {
      setFileDropEnabled(true);
      unlisteners.push(unlisten);
    });

    listen(TauriEvent.WINDOW_FILE_DROP_CANCELLED, () => {
      setIsListening(false);
      setFileList([]);
      setFileDropEnabled(false);
      setFileDropped(false);
    }).then((unlisten) => {
      unlisteners.push(unlisten);
    });

    listen(TauriEvent.WINDOW_FILE_DROP, async (event: Event<string[]>) => {
      setFileDropped(true);
      setIsListening(false);
      setFileDropEnabled(false);

      if (event.payload.length === 0) {
        return;
      }
      setFileList(event.payload.filter(isMcPack));
    }).then((unlisten) => {
      unlisteners.push(unlisten);
      setFileDropped(false);
    });

    return () => {
      unlisteners.forEach((unlisten) => unlisten());
    };
  }, []);

  return (
    <div className={clsx(fileDropEnabled && "file-drop")}>
      <PlusIcon className="h-8 w-8 text-gray-100/80" />
      {isListening && <p>Listening for file drop</p>}
      <div className="container mx-auto empty:hidden">
        {fileDropped &&
          fileList.map((file) => <PackUploadEntry key={file} src={file} />)}
      </div>
    </div>
  );
}
