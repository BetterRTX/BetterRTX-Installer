import { useState, useEffect } from "react";
import { Command } from "@tauri-apps/api/shell";
import { useMinecraftProcess } from "./useMinecraftProcess";

export interface HookSideload {
  sideload: (destination: string) => Promise<{ result: string }>;
  stdout: string[];
  errors: string[];
  reset: () => void;
}

export function useSideload() {
  const [errors, setErrors] = useState<string[]>([]);
  const [stdout, setStdOut] = useState<string[]>([]);
  const { getProcessId } = useMinecraftProcess();
  return {
    stdout,
    errors,
    async sideload(destination: string): Promise<boolean> {
      const pid = await getProcessId();

      if (!pid) {
        throw new Error("Minecraft not running");
      }

      const cmd = new Command("UWPInjector", [
        "-p",
        pid.toString(),
        "-d",
        destination,
      ]);

      cmd.stdout.on("data", (line) => {
        setStdOut((lines) => [...lines, line]);
      });

      cmd.stderr.on("data", (line) => {
        setErrors((lines) => [...lines, line]);
      });

      cmd.on("error", async (error) => {
        await child.kill();
        throw new Error(`Sideloading failed: ${error}`);
      });

      const res: Promise<boolean> = new Promise((resolve, reject) => {
        cmd.on("close", (data) => {
          if (data.code === 0) {
            resolve(true);
            return;
          }

          reject(new Error(`Sideloading failed: ${data.stderr}`));
        });
      });
      const child = await cmd.spawn();

      return res;
    },
    reset() {
      setErrors([]);
      setStdOut([]);
    },
  };
}
