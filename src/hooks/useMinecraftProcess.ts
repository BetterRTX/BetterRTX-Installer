"use client";
import type { InstanceList, InstanceName } from "@/types";
import { exists } from "@tauri-apps/api/fs";
import { Command } from "@tauri-apps/api/shell";
import { useSetupInstanceStore } from "@/store/instanceStore";
import { runCommand } from "@/lib";
import {
  MINECRAFT_NAME,
  MINECRAFT_PREVIEW_NAME,
  MINECRAFT_EXECUTABLE_NAME,
} from "@/lib/constants";
import { useSetupStore } from "@/store/setupStore";

type PackageInfo = Record<
  string,
  {
    name: string;
    location: string;
  }
>;

export interface HookMinecraftProcess {
  locations: Record<string, string>;
  instancesLoading: boolean;
  getExePath: (instance: string) => Promise<string | null>;
  getInstanceName: (instance: string) => InstanceName;
  getInstanceList: () => Promise<InstanceList>;
  refreshLocations: () => Promise<void>;
  getPackage: (
    instance: string,
  ) => Promise<PackageInfo[keyof PackageInfo] | undefined>;
  getProcessId: () => Promise<number>;
  isPreviewInstance: (instance: string) => Promise<boolean>;
  sideload: (destination: string) => Promise<{ result: string }>;
  launchBetterRenderDragon: (instance: string) => Promise<void>;
}

async function getProcessId() {
  const { resolveResource } = await import("@tauri-apps/api/path");
  const { processID } = await runCommand<{
    processID?: number;
  }>("run-script", [
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    await resolveResource("../resources/script/minecraft_process_id.ps1"),
  ]);

  return Number(processID);
}

async function refreshLocations() {
  const { resolveResource } = await import("@tauri-apps/api/path");
  try {
    const locations = await runCommand<Record<string, string>>("run-script", [
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      await resolveResource("../resources/script/minecraft_locations.ps1"),
    ]);

    useSetupStore.setState({ locations });
  } catch (error) {
    console.error(error);
    useSetupStore.setState({ locations: {} });
  }
}

function getInstanceName(instance: string): InstanceName {
  return instance.toLowerCase().includes("beta")
    ? MINECRAFT_PREVIEW_NAME
    : MINECRAFT_NAME;
}

async function getPackage(instance: string) {
  const { resolveResource } = await import("@tauri-apps/api/path");
  try {
    const res = await runCommand<PackageInfo>("run-script", [
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      await resolveResource("../resources/script/minecraft_package.ps1"),
    ]);
    const appxPackage = Object.values(res).find(
      (pkg) =>
        (pkg.name.toLowerCase().includes("beta") &&
          instance === MINECRAFT_PREVIEW_NAME) ||
        instance === MINECRAFT_NAME,
    );

    return appxPackage;
  } catch (error) {
    console.error(error);
    return undefined;
  }
}

export function useMinecraftProcess(): HookMinecraftProcess {
  const instancesLoading = useSetupInstanceStore(
    (state) => state.instancesLoading,
  );

  const sideloadInstances = useSetupStore((state) => state.sideloadInstances);
  const locations = useSetupStore((state) => state.locations);

  return {
    locations,
    instancesLoading,
    getInstanceName,
    getProcessId,
    refreshLocations,
    getPackage,
    async isPreviewInstance(instance: string) {
      const { join } = await import("@tauri-apps/api/path");
      const assetsPath = await join(
        sideloadInstances[instance].location,
        "UAP.Preview.Assets",
      );
      const pathExists = await exists(assetsPath);

      return pathExists;
    },
    async getExePath(instance: string) {
      const { join } = await import("@tauri-apps/api/path");
      const exePath = await join(
        sideloadInstances[instance].location,
        MINECRAFT_EXECUTABLE_NAME,
      );

      const exeExists = await exists(exePath);

      return exeExists ? exePath : null;
    },
    async getInstanceList() {
      useSetupInstanceStore.setState({ instancesLoading: true });

      const instances = Object.fromEntries(
        Object.entries(locations).map(([name, location]) => {
          return [getInstanceName(name), { location, name }];
        }),
      ) as InstanceList;

      useSetupInstanceStore.setState({ instances, instancesLoading: false });

      return instances;
    },
    async sideload(destination: string): Promise<{ result: string }> {
      const cmd = new Command("UWPInjector", [
        "-p",
        String(await getProcessId()),
        "-d",
        destination,
      ]);

      const res = new Promise((resolve, reject) => {
        cmd.on("close", (data) => {
          if (data.code === 0) {
            resolve({ result: "success" });
            return;
          }

          reject(new Error(`Sideloading failed: ${data.stderr}`));
        });
        cmd.on("error", (error) => {
          throw new Error(`Sideloading failed: ${error}`);
        });
        cmd.stdout.on("data", (line) =>
          resolve({ result: `Sideloading: ${line}` }),
        );
        cmd.stderr.on("data", (line) =>
          reject(new Error(`Sideloading failed: ${line}`)),
        );
      });
      await cmd.spawn();
      return {
        result: (await res) as string,
      };
    },
    async launchBetterRenderDragon(instance: string) {
      const res = (await getPackage(instance)) ?? {
        name: undefined,
      };

      if (!res.name) {
        throw new Error("Minecraft UWP package not found");
      }

      console.log("launching better render dragon");
      const cmd = new Command("uwpinject", [res.name]);
      const response = await cmd.execute();
      console.log(response);
    },
  };
}
