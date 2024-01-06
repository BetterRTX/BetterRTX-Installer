"use client";
import { Cross2Icon, CheckIcon } from "@radix-ui/react-icons";

export function ErrorButton({
  dismiss,
  error,
}: {
  dismiss: () => void;
  error?: string | null;
}) {
  return (
    <div className="absolute right-0 top-0 z-30 mt-0 w-12 overflow-hidden rounded-lg shadow-xl backdrop-blur-lg">
      <button
        className="btn inline-flex h-12 w-12  justify-center overflow-hidden rounded-lg border border-minecraft-red-200/50 bg-minecraft-red-500/60 py-0 shadow-md outline-none hover:bg-minecraft-red-700/90 focus:bg-minecraft-red-300/80 focus:outline-none active:bg-minecraft-red-800/75 active:outline-none"
        title={error ?? "Error"}
        type="button"
        onClick={dismiss}
      >
        <Cross2Icon className="h-8 w-8 text-red-200 drop-shadow" />
      </button>
    </div>
  );
}

export function SuccessButton() {
  return (
    <div className="absolute right-0 top-0 z-30 mt-0 w-12 overflow-hidden rounded-lg shadow-xl backdrop-blur-lg">
      <div className="btn inline-flex h-12 w-12  justify-center overflow-hidden rounded-lg border border-minecraft-green-200/50 bg-minecraft-green-300/60 py-0 shadow-md outline-none hover:bg-minecraft-green-700/90 focus:bg-minecraft-green-300/80 focus:outline-none active:bg-minecraft-green-800/75 active:outline-none">
        <CheckIcon className="h-8 w-8 text-green-200 drop-shadow" />
      </div>
    </div>
  );
}
