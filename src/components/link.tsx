"use client";
import { DataInteractive as HeadlessDataInteractive } from "@headlessui/react";
import NextLink, { type LinkProps } from "next/link";
import {
  type ComponentPropsWithoutRef,
  type ForwardedRef,
  forwardRef,
} from "react";

export const Link = forwardRef(function Link(
  props: LinkProps & ComponentPropsWithoutRef<"a">,
  ref: ForwardedRef<HTMLAnchorElement>,
) {
  return (
    <HeadlessDataInteractive>
      <NextLink {...props} ref={ref} />
    </HeadlessDataInteractive>
  );
});
