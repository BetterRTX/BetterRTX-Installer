"use client";
import { useEffect, useState } from "react";
import { Transition } from "@headlessui/react";
import { useMcPack } from "@/hooks/useMcPack";
import PackList from "@/components/mod/PackList";
import { Pack } from "@/types";
import { useTranslation } from "react-i18next";

export default function Page() {
  const { getPacks } = useMcPack();
  const [packs, setPacks] = useState<Pack[]>([]);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const { t } = useTranslation();

  useEffect(() => {
    setLoading(true);
    setErrorMessage(null);
    getPacks()
      .then((p) => {
        setPacks(p);
      })
      .catch((e) => {
        setErrorMessage(e.message);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [getPacks]);

  const hasPacks = packs.length > 0;

  return (
    <div className="relative flex h-screen min-w-96 flex-col">
      {errorMessage && <p className="error-message">{errorMessage}</p>}
      <main className="container mx-auto px-4 py-2">
        {loading && (
          <div>
            <h1 className="text-center text-4xl font-bold leading-relaxed text-opacity-50">
              {t("mod.loading")}
            </h1>
          </div>
        )}
        <Transition
          show={hasPacks}
          enter="transition-all duration-200"
          enterFrom="opacity-0 -translate-y-4"
          enterTo="opacity-100 translate-y-0"
          leave="transition-opacity duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <PackList packs={packs} />
        </Transition>
      </main>
    </div>
  );
}
