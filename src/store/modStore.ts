"use client";

import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import type { Pack } from "@/types";

export interface ModState {
  packs: Pack[];
  addPack(pack: Pack): void;
  getPack(uuid: string): Pack | undefined;
}

export const useModStore = create<ModState>()(
  persist(
    (set, get) => ({
      packs: [] as Pack[],
      addPack: (pack: Pack) =>
        set((state) => {
          const existing = state.packs.find((p) => p.uuid === pack.uuid);

          if (existing) {
            existing.name = pack.name;
            existing.title = pack.title;
            existing.path = pack.path;
            return state;
          }

          state.packs.push(pack);

          return state;
        }),
      getPack: (uuid: string) => {
        return get().packs.find((pack) => pack.uuid === uuid);
      },
    }),
    {
      name: "mod-storage",
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
