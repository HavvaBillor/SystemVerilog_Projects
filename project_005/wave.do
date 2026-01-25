onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_pwm/CLK_PERIOD
add wave -noupdate /tb_pwm/PWM_FREQ
add wave -noupdate /tb_pwm/PWM_PERIOD_NS
add wave -noupdate /tb_pwm/clk
add wave -noupdate /tb_pwm/rst_n
add wave -noupdate -radix unsigned /tb_pwm/duty_cycle
add wave -noupdate /tb_pwm/pwm_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19830153808 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {26250105 ns}
