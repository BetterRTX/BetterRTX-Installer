"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

export interface SideloadInstances {
  [key: string]: {
    location: string;
    preview: boolean;
  };
}

export interface SetupState {
  locations: Record<string, string>;
  sideloadInstances: SideloadInstances;
  unlockerProcess: string | null;
  unlockerArgs: string[] | null;
  setUnlockerProcess: (process: string) => void;
  setUnlockerArgs: (args: string[]) => void;
  getSideLoadInstance: (key: string) => SideloadInstances[string];
  setSideloadInstance: (
    key: string,
    location: string,
    preview?: boolean,
  ) => void;
  removeSideloadInstance: (key: string) => void;
}

export const useSetupStore = create<SetupState>()(
  persist(
    (set, get) => ({
      locations: {},
      sideloadInstances: {},
      unlockerProcess: null,
      unlockerArgs: null,
      setUnlockerProcess: (unlockerProcess: string) => set({ unlockerProcess }),
      setUnlockerArgs: (unlockerArgs: string[]) => set({ unlockerArgs }),
      getSideLoadInstance: (key: string) => {
        return (
          get().sideloadInstances[key] ?? {
            location: "",
            preview: false,
          }
        );
      },
      setSideloadInstance: (
        key: string,
        sideloadPath: string,
        preview = false,
      ) => {
        if (key === "") {
          throw new Error("Key cannot be empty");
        }

        if (sideloadPath.startsWith("C:\\Program Files\\WindowsApps")) {
          throw new Error("Sideload path cannot be in WindowsApps");
        }

        return set((state) => {
          const sideloadInstances = { ...state.sideloadInstances };
          sideloadInstances[key] = { location: sideloadPath, preview };
          return { sideloadInstances };
        });
      },
      removeSideloadInstance: (key: string) => {
        return set((state) => {
          const sideloadInstances = { ...state.sideloadInstances };
          delete sideloadInstances[key];
          return { sideloadInstances };
        });
      },
    }),
    {
      name: "setup-storage",
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
