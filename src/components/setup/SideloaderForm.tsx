"use client";
import { useEffect, useState, useId } from "react";
import { withTranslation } from "react-i18next";
import { useSetupStore } from "@/store/setupStore";
import SideloadLocation from "./SideloadLocation";

function SideloaderForm({ t }: { t: (key: string) => string }) {
  const sideloaderNameId = useId();
  const [newInstanceName, setNewInstanceName] = useState<string>("");
  const { sideloadInstances, setSideloadInstance } = useSetupStore();

  const instanceKeys = Object.keys(sideloadInstances);

  useEffect(() => {
    if (!sideloadInstances[newInstanceName]) {
      instanceKeys.push(newInstanceName);
    }
  }, [sideloadInstances, newInstanceName, instanceKeys]);

  return (
    <form className="space-y-6">
      <div className="flex flex-col space-y-0.5 border-b border-gray-500/50 px-2 pb-6">
        <label className="input-label" htmlFor={sideloaderNameId}>
          {t("setup.sideloading.instanceNameLabel")}
        </label>
        <div className="flex space-x-2">
          <input
            id={sideloaderNameId}
            className="input flex-grow "
            type="text"
            placeholder={t("setup.sideloading.instanceNamePlaceholder")}
            value={newInstanceName}
            onChange={(e) => setNewInstanceName(e.target.value)}
          />
          <button
            className="btn w-48 hover:bg-white/15 disabled:hover:bg-white/5"
            type="button"
            onClick={() => {
              setSideloadInstance(newInstanceName, "");
              setNewInstanceName("");
            }}
            disabled={
              newInstanceName.length < 1 ||
              instanceKeys.includes(newInstanceName)
            }
          >
            {t("setup.sideloading.addInstance")}
          </button>
        </div>
      </div>
      {instanceKeys.length > 0 && (
        <div className="flex flex-col items-start justify-center space-y-4">
          {instanceKeys.map(
            (instanceName) =>
              instanceName.length > 0 && (
                <SideloadLocation key={instanceName} {...{ instanceName }} />
              ),
          )}
        </div>
      )}
    </form>
  );
}

export default withTranslation()(SideloaderForm);
