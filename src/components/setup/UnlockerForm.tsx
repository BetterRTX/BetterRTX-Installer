"use client";
import { useId, useState } from "react";
import { open } from "@tauri-apps/api/dialog";
import { useSetupStore } from "@/store/setupStore";

export default function UnlockerForm() {
  const unlockerArgsId = useId();
  const unlockerArgsDescriptionId = useId();
  const { setUnlockerProcess, setUnlockerArgs, unlockerArgs, unlockerProcess } =
    useSetupStore();
  const [unlockerArguments, setUnlockerArguments] = useState<string[] | null>(
    unlockerArgs,
  );

  const handleSaveArguments = async () => {
    setUnlockerArgs(unlockerArguments?.filter((arg) => arg.length) ?? []);
  };

  const handleSaveExecutablePath = async () => {
    const result = await open({
      title: "Select unlocking executable",
      multiple: false,
      directory: false,
      filters: [
        {
          extensions: ["exe"],
          name: "Executable",
        },
      ],
    });
    if (result) {
      setUnlockerProcess(Array.isArray(result) ? result[0] : result);
    }
  };

  return (
    <form className="card space-y-3 p-3">
      <fieldset className="flex flex-col space-y-1 px-2">
        <legend className="font-medium text-gray-50">
          Start Process Command
        </legend>
        <div className="flex items-center justify-start space-x-2">
          {unlockerProcess === null ? (
            <p className="input mr-auto flex-grow select-none text-gray-400">
              No executable selected
            </p>
          ) : (
            <p className="input mr-auto flex-grow select-all text-gray-200">
              {unlockerProcess}
            </p>
          )}
          <button
            className="btn w-32 hover:bg-white/15"
            type="button"
            onClick={handleSaveExecutablePath}
          >
            Select
          </button>
        </div>
        <div className="flex flex-col items-start justify-center space-y-1">
          <label
            className="text-sm font-medium text-gray-50"
            htmlFor={unlockerArgsId}
          >
            Arguments
          </label>
          <div className="flex w-full items-center justify-start space-x-2">
            <input
              className="input flex-grow"
              type="text"
              placeholder='/Copy `"$source`" `"$dest`"'
              value={unlockerArguments?.join(" ") ?? ""}
              id={unlockerArgsId}
              aria-describedby={unlockerArgsDescriptionId}
              onChange={(e) =>
                setUnlockerArguments(e.target.value.split(/\s+/))
              }
            />
            <button
              className="btn w-32 hover:bg-white/15"
              type="button"
              onClick={handleSaveArguments}
            >
              Save
            </button>
          </div>
          <p
            id={unlockerArgsDescriptionId}
            className="cursor-default select-none text-xs leading-relaxed text-gray-200"
          >
            Use variables{" "}
            <code className="font-medium hover:cursor-pointer hover:underline">
              $source
            </code>{" "}
            and{" "}
            <code className="font-medium hover:cursor-pointer hover:underline">
              $dest
            </code>{" "}
            for input and output paths respectively.
          </p>
        </div>
      </fieldset>
    </form>
  );
}
