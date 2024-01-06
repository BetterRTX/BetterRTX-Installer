"use client";
import { useState, useLayoutEffect, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { RadioGroup, Transition } from "@headlessui/react";
import PackEntry from "@/components/mod/PackEntry";
import type { IPack } from "@/types";
import { useSubpacks } from "@/hooks/useMcPack";
import { useModStore } from "@/store";

export default function PackList({ packs }: { packs: IPack[] }) {
  const { open } = useSubpacks();
  const { t } = useTranslation();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [selectedPack, setSelectedPack] = useState<IPack | null>(null);

  // useEffect(() => {
  //   setErrorMessage(null);
  //   open().catch((e) => {
  //     setErrorMessage(e.message);
  //   });
  // }, [open]);

  return (
    <div className="relative h-full w-full">
      <Transition
        show={!!selectedPack}
        enter="transition-opacity duration-150"
        enterFrom="opacity-0"
        enterTo="opacity-100"
        leave="transition-opacity duration-150"
        leaveFrom="opacity-100"
        leaveTo="opacity-0"
      >
        {selectedPack && (
          <img
            className="fixed left-0 top-0 z-0 h-screen w-full object-cover"
            src={`https://bedrock.graphics/api/pack/${selectedPack?.uuid}/banner`}
            alt={selectedPack?.title}
          />
        )}
        <div className="fixed left-0 top-0 z-10 h-full w-full bg-black bg-opacity-50" />
      </Transition>

      <div className="absolute left-0 top-0 z-20 h-full w-full">
        <header className="mb-4 mr-auto mt-2 text-left">
          <h1 className="text-xl font-bold leading-relaxed text-gray-50/90">
            {t("mod.title")}
          </h1>
          <p className="text-sm font-medium text-gray-100/80">
            {t("mod.description")}
          </p>
        </header>
        <div className="card flex-grow divide-y divide-gray-700/50 bg-minecraft-slate-700/50 shadow-lg">
          <RadioGroup
            value={selectedPack}
            onChange={(value) => {
              setSelectedPack(value);
            }}
            className="divide-y divide-gray-700/50"
          >
            {packs.map((pack) => (
              <RadioGroup.Option key={pack.path} value={pack}>
                <PackEntry pack={pack} />
              </RadioGroup.Option>
            ))}
          </RadioGroup>
        </div>
      </div>
    </div>
  );
}
