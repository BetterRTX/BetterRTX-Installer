"use client";
import { useEffect, useState } from "react";
import PackUpload from "@/components/mod/PackUpload";
import PackList from "@/components/mod/PackList";
import { useModStore } from "@/store";
import type { IPack } from "@/types";
import { Transition } from "@headlessui/react";

export default function Page() {
  const { packs } = useModStore();
  const [packList, setPackList] = useState<IPack[]>([]);

  useEffect(() => {
    setPackList(packs);
  }, [packs]);

  return (
    <div className="relative flex h-screen min-w-96 flex-col">
      <PackUpload />
      <main className="container mx-auto px-4 py-2">
        <Transition
          show={packList.length > 0}
          enter="transition-opacity duration-150"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="transition-opacity duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <PackList packs={packList} />
        </Transition>
      </main>
    </div>
  );
}
