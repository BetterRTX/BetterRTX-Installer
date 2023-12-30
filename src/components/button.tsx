"use client";
import { Button as HeadlessButton, type ButtonProps } from "@headlessui/react";
import { clsx } from "clsx";
import { forwardRef, type ForwardedRef, type ReactNode } from "react";
import NextLink, { type LinkProps } from "next/link";

export const Button = forwardRef(function Button(
  {
    className,
    children,
    ...props
  }: (ButtonProps | LinkProps) & { children: ReactNode; className?: string },
  ref: ForwardedRef<HTMLElement>,
) {
  const classes = clsx("btn", className);

  return "href" in props ? (
    <NextLink
      {...props}
      className={classes}
      ref={ref as ForwardedRef<HTMLAnchorElement>}
    >
      <span className="btn__upper-border"></span>
      <span className="btn__left-border"></span>
      <TouchTarget>{children}</TouchTarget>
      <span className="btn__lower-border"></span>
      <span className="btn__right-border"></span>
    </NextLink>
  ) : (
    <HeadlessButton className={classes} ref={ref} {...props}>
      <span className="btn__upper-border"></span>
      <span className="btn__left-border"></span>
      <TouchTarget>{children}</TouchTarget>
      <span className="btn__lower-border"></span>
      <span className="btn__right-border"></span>
    </HeadlessButton>
  );
});

/* Expand the hit area to at least 44×44px on touch devices */
export function TouchTarget({ children }: { children: ReactNode }) {
  return (
    <>
      {children}
      <span
        className="absolute left-1/2 top-1/2 size-[max(100%,2.75rem)] -translate-x-1/2 -translate-y-1/2 [@media(pointer:fine)]:hidden"
        aria-hidden="true"
      />
    </>
  );
}
