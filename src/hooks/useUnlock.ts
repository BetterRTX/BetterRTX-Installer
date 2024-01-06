"use client";
import { useState } from "react";
import { Command } from "@tauri-apps/api/shell";
import { useSetupStore } from "@/store/setupStore";

export interface HookUnlock {
  unlockFile: (file: string, dest: string) => Promise<boolean>;
  result: string[];
  error: Error | null;
}

export function useUnlock(): HookUnlock {
  const [error, setError] = useState<Error | null>(null);
  const [result, setResult] = useState<string[]>([]);
  const { unlockerArgs, unlockerProcess } = useSetupStore();
  return {
    error,
    result,
    async unlockFile(src: string, dest: string) {
      const { join, basename } = await import("@tauri-apps/api/path");
      const filename = await basename(src);
      const args = (unlockerArgs ?? [])
        .join(" ")
        .replace(/\$dest/g, `"${await join(dest, filename)}"`)
        .replace(/\$source/g, `"${src}"`);

      console.log(args);

      const cmd = new Command("run-shell", [
        "Start-Process",
        "-FilePath",
        `"${unlockerProcess}"`,
        "-ArgumentList",
        `'${args}'`,
        "-Wait",
      ]);
      const { stdout, stderr, code } = await cmd.execute();

      if (stderr) {
        setError(
          new Error(stderr, {
            cause: code,
          }),
        );
      }

      setResult(stdout.trim().split("\n"));

      return code === 0;
    },
  };
}
