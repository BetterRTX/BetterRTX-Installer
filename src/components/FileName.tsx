"use client";
import { isValidMaterial } from "@/lib";
import { MATERIAL_SUFFIX } from "@/lib/constants";
export default function FileName({ file }: { file: string }) {
  const filePath = file.replace(MATERIAL_SUFFIX, "").split("/");
  const name = filePath.pop() ?? "";

  return (
    <p className="text-xs leading-tight">
      <span className="text-gray-600">{filePath.join("/")}/</span>

      {isValidMaterial(name) ? (
        <>
          <span className="font-medium text-green-500">
            {name.replace(MATERIAL_SUFFIX, "")}
          </span>
          <span className="text-blue-400/50">{MATERIAL_SUFFIX}</span>
        </>
      ) : (
        <span className="h-4 w-4 text-gray-400">{name}</span>
      )}
    </p>
  );
}
