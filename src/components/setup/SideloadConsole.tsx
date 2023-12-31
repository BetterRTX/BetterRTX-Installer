"use client";
import type { HookSideload } from "@/hooks";
import { useTranslation } from "react-i18next";

export default function SideloadConsole({
  stdout,
}: Pick<HookSideload, "stdout">) {
  const { t } = useTranslation();
  return (
    <div className="flex flex-col border-2 border-minecraft-slate-900 bg-minecraft-slate-900/50 shadow-inner last:rounded-b-lg empty:hidden">
      <h5 className="border-b border-b-minecraft-slate-500/50 bg-minecraft-slate-900/50 px-4 py-2 text-sm font-medium capitalize text-gray-300 shadow-sm">
        {t("setup.sideloading.consoleTitle")}
      </h5>
      <div className="h-32 flex-1 overflow-auto bg-minecraft-slate-900/75 px-4 pb-4 pt-2 font-mono">
        <pre className="cursor-pointer select-all text-xs text-gray-500">
          {stdout
            .map((s) => s.trim())
            .filter((l) => l.length)
            .join("\n")}
        </pre>
      </div>
    </div>
  );
}
