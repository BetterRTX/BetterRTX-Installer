"use client";

import { Command } from "@tauri-apps/api/shell";
import type { InstanceList, InstanceName } from "@/types";
import { useSetupInstanceStore } from "@/store/instanceStore";
import { runCommand } from "@/lib";
import { MINECRAFT_NAME, MINECRAFT_PREVIEW_NAME } from "@/lib/constants";

export interface SideloaderSetup {
  exe: string;
}

export interface HookMinecraftLocations {
  instancesLoading: boolean;
  getInstanceName: (instance: string) => InstanceName;
  getInstanceList: () => Promise<InstanceList>;
  getRunningInstance: () => Promise<InstanceName | null>;
  getLocations: () => Promise<Record<string, string>>;
  getProcessId: () => Promise<number>;
  sideload: (destination: string) => Promise<string>;
  launchBetterRenderDragon: (instance: string) => Promise<void>;
  unlocker: (
    process: string,
    args: string[],
    source: string,
    dest: string,
  ) => Promise<Record<string, string>>;
}

async function getProcessId() {
  const { processID } = await runCommand<{
    processID?: number;
  }>("get-minecraft-process-id");

  return Number(processID);
}

async function getLocations() {
  const locations = await runCommand<Record<string, string>>(
    "get-minecraft-locations",
  );

  return locations;
}

function getInstanceName(instance: string): InstanceName {
  return instance.toLowerCase().includes("beta")
    ? MINECRAFT_PREVIEW_NAME
    : MINECRAFT_NAME;
}

export function useMinecraftProcess(): HookMinecraftLocations {
  const instancesLoading = useSetupInstanceStore(
    (state) => state.instancesLoading,
  );

  return {
    instancesLoading,
    getInstanceName,
    getProcessId,
    getLocations,
    async getRunningInstance() {
      const { name, preview } = await runCommand<{
        name: InstanceName;
        preview: boolean | null;
      }>("get-running-instance");

      if (preview) {
        return MINECRAFT_PREVIEW_NAME;
      }

      return name;
    },
    async getInstanceList() {
      useSetupInstanceStore.setState({ instancesLoading: true });
      const locations = await getLocations();

      const instances = Object.fromEntries(
        Object.entries(locations).map(([name, location]) => {
          return [getInstanceName(name), { location, name }];
        }),
      ) as InstanceList;

      useSetupInstanceStore.setState({ instances, instancesLoading: false });

      return instances;
    },
    async unlocker(
      process: string,
      args: string[],
      source: string,
      dest: string,
    ) {
      const cmd = new Command("unlocker", [
        "Start-Process",
        "-FilePath",
        process,
        "-ArgumentList",
        args.join(" ").replace(/\$(source|dest)/gi, (match) => {
          if (match === "$source") {
            return source;
          }

          if (match === "$dest") {
            return dest;
          }

          return match;
        }),
        "-Wait",
      ]);

      const response = await cmd.execute();

      if (response.code !== 0) {
        throw new Error(`Unlock failed: ${response.stderr}`, {
          cause: response.code,
        });
      }

      return JSON.parse(response.stdout);
    },
    async sideload(destination: string) {
      const cmd = new Command("sideload-minecraft", [
        destination,
      ]);

      const response = await cmd.execute();

      if (response.code !== 0) {
        throw new Error(`Sideloading failed: ${response.stderr}`, {
          cause: response.code,
        });
      }

      return JSON.parse(response.stdout);
    },
    async launchBetterRenderDragon(instance: string) {
      console.log("launching better render dragon");
      const cmd = Command.sidecar(
        "../resources/bin/BetterRenderDragon/uwpinject",
        [
          instance,
        ],
      );
      const response = await cmd.execute();
      console.log(response);
    },
  };
}
