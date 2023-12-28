"use client";
import { Command, type SpawnOptions } from "@tauri-apps/api/shell";

export async function runCommand<T>(
  commandName: string,
  args?: string | string[],
  options?: SpawnOptions,
): Promise<T> {
  const cmd = new Command(commandName, args, options);
  const response = await cmd.execute();
  return JSON.parse(response.stdout) satisfies T;
}
