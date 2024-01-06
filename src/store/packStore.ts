"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import type { IPack } from "@/types";

export interface PackState {
  isExtracting: boolean;
  files: string[];
  packDirectory: string | null;
  error: Error | null;
  progress: number;
  getProgress: () => number;
}

export const createPackStore = (pack: IPack) => {
  const store = create<PackState>()(
    persist(
      (set, get) => ({
        isExtracting: false,
        files: [],
        packDirectory: null,
        error: null,
        progress: 0,
        getProgress: () => get().progress / get().files.length || 0,
      }),
      {
        name: `pack-${pack.uuid}`,
        storage: createJSONStorage(() => sessionStorage),
        partialize: ({ files, packDirectory }) => ({
          files,
          packDirectory,
        }),
      },
    ),
  );

  return {
    ...store,
    setPackDirectory: (packDirectory: string) =>
      store.setState({ packDirectory }),
    setFiles: (files: string[]) => store.setState({ files }),
    setError: (error: Error) => store.setState({ error }),
    setProgress: (progress: number) => store.setState({ progress }),
    setIsExtracting: (isExtracting: boolean) =>
      store.setState({ isExtracting }),
  };
};
