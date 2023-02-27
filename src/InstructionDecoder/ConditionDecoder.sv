`include "../Utilities/InstructionTypes.sv"

import Condition::Condition_Value;

module ConditionDecoder (
    input clk,
    input reset,
    input[3:0] cond_encoded,
    output Condition_Value cond_decoded
);
    always_ff @ (posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            cond_decoded = Condition::Equal;
        end else begin
            case (cond_encoded) 
            4'h0: begin
                cond_decoded = Condition::Equal;
            end
            4'h1: begin
                cond_decoded = Condition::NotEqual;
            end
            4'h2: begin
                cond_decoded = Condition::UnsignedHigherSame;
            end
            4'h3: begin
                cond_decoded = Condition::UnsignedLower;
            end
            4'h4: begin
                cond_decoded = Condition::Negative;
            end
            4'h5: begin
                cond_decoded = Condition::PositiveZero;
            end
            4'h6: begin
                cond_decoded = Condition::Overflow;
            end
            4'h7: begin
                cond_decoded = Condition::NoOverflow;
            end
            4'h8: begin
                cond_decoded = Condition::UnsignedHigher;
            end
            4'h9: begin
                cond_decoded = Condition::UnsignedLowerSame;
            end
            4'hA: begin
                cond_decoded = Condition::GreaterEqual;
            end
            4'hB: begin
                cond_decoded = Condition::LessThan;
            end
            4'hC: begin
                cond_decoded = Condition::GreaterThan;
            end
            4'hD: begin
                cond_decoded = Condition::LessThanEqual;
            end
            4'hE: begin
                cond_decoded = Condition::Always;
            end
            4'hF: begin
                cond_decoded = Condition::Undefined;
            end
            endcase
        end
    end

endmodule
